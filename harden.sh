#!/usr/bin/env bash
# ========================================================================
# Script:        harden.sh
# Description:   This script has been designed to harden Ubuntu Linux servers
#                in order to pass benchmarks related with the Spanish ENS and
#                the CIS guide for Ubuntu.
# Usage:         chmod +x harden.sh; sudo ./harden.sh
# Tested on:     Ubuntu 24.04 LTS
# Author:        Iván Texenery Díaz García (ivantexenery@gmail.com)
# Version:       1.0.0 (2025-09-15)
# License:       GPL-3.0-or-later
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2025 Iván Texenery Díaz García
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version. See the LICENSE file for details.       
# =======================================================================
export DEBIAN_FRONTEND=noninteractive
AUTHORIZED_TEXT="

Put something useful to warn about the consequences of a bad use of the systems

"
HOSTS_ALLOW_TEXT="
sshd: --> put networks which from can access using ssh login 
slapd: --> put networks which from can validate across LDAP/Kerberos
"
SUPPORT_MAIL="
Put the mail which will receive the alerts, such as the space left on device alert.
"
POSTFIX_DOMAIN="
mydomain.net
"
POSTFIX_IP="
my_relay_ip
"

#########################################################################
# 0) Establish system language
#########################################################################
sudo sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
sudo update-locale LANG=en_US.UTF-8 LC_MESSAGES=en_US.UTF-8 LANGUAGE=en_US:en
unset LC_ALL
. /etc/default/locale

#########################################################################
# 1) Install PAM password quality module
#########################################################################
apt-get update -y || true
apt-get install -y libpam-pwquality
apt-get install aide aide-common -y
apt-get install -y audispd-plugins
apt-get install -y systemd-timesyncd
apt-get install -y systemd-journal-remote
apt-get install -y systemd-coredump
apt-get install -y apparmor apparmor-utils

#########################################################################
# 2) Configurate pamd.d files
#########################################################################
grep -E '^\s*auth\s*required\s*pam_wheel.so\s*use_uid\s*group\s*=\s*.*'  /etc/pam.d/su && \
sed -i 's/^\s*auth\s*required\s*pam_wheel.so\s*use_uid\s*group\s*=\s*.*/auth required pam_wheel.so use_uid group=admins/'\
/etc/pam.d/su || echo 'auth required pam_wheel.so use_uid group=admins' >> /etc/pam.d/su

cat >/etc/pam.d/common-password <<'EOF'
# here are the per-package modules (the "Primary" block)
password        requisite                       pam_pwquality.so try_first_pass retry=3 minlen=8 minclass=3 difok=3
password        requisite                       pam_pwhistory.so remember=7 use_authtok
password        [success=3 default=ignore]      pam_krb5.so minimum_uid=5000
password        [success=2 default=ignore]      pam_unix.so obscure use_authtok try_first_pass yescrypt
password        [success=1 user_unknown=ignore default=die]     pam_ldap.so use_authtok try_first_pass
# here's the fallback if no module succeeds
password        requisite                       pam_deny.so
password        required                        pam_permit.so
EOF

cat >/etc/pam.d/common-auth <<'EOF'
# here are the per-package modules (the "Primary" block)
auth    [success=3 default=ignore]      pam_krb5.so minimum_uid=5000
auth    [success=2 default=ignore]      pam_unix.so try_first_pass
auth    [success=1 default=ignore]      pam_ldap.so use_first_pass
auth    requisite                       pam_deny.so
auth    required                        pam_permit.so
auth    optional                        pam_cap.so
EOF

find /etc/pam.d/ -type f -exec sed -i -E 's/(^|[[:space:]])nullok([[:space:]]|$)/\1\2/g' {} +

#########################################################################
# 3) Configurate pam configs
#########################################################################
cat > /usr/share/pam-configs/unix_cis <<'EOF'
Name: Unix authentication
Default: yes
Priority: 256
Auth-Type: Primary
Auth:
        [success=end default=ignore]    pam_unix.so try_first_pass
Auth-Initial:
        [success=end default=ignore]    pam_unix.so
Account-Type: Primary
Account:
        [success=end new_authtok_reqd=done default=ignore]      pam_unix.so
Account-Initial:
        [success=end new_authtok_reqd=done default=ignore]      pam_unix.so
Session-Type: Additional
Session:
        required        pam_unix.so
Session-Initial:
        required        pam_unix.so
Password-Type: Primary
Password:
        [success=end default=ignore]    pam_unix.so obscure use_authtok try_first_pass yescrypt
Password-Initial:
        [success=end default=ignore]    pam_unix.so obscure yescrypt
EOF
cat > /usr/share/pam-configs/pwhistory_cis <<'EOF'
Name: pwhistory
Default: yes
Priority: 1024

Password-Type: Primary
Password:
        requisite pam_pwhistory.so remember=24 enforce_for_root use_authtok
Name: pwhistory
Default: yes
Priority: 1024

Password-Type: Primary
Password:
        requisite pam_pwhistory.so remember=24 enforce_for_root use_authtok
EOF
cat > /usr/share/pam-configs/pwquality_cis <<'EOF'
Name: Pwquality password strength checking
Default: yes
Priority: 1024
Conflicts: cracklib
Password-Type: Primary
Password:
        requisite                       pam_pwquality.so retry=3
Password-Initial:
        requisite                       pam_pwquality.so retry=3
EOF
DEBIAN_FRONTEND=noninteractive pam-auth-update --disable pwquality_cis pwhistory_cis unix_cis --package --force
DEBIAN_FRONTEND=noninteractive pam-auth-update --enable pwquality_cis pwhistory_cis unix_cis --package --force
DEBIAN_FRONTEND=noninteractive pam-auth-update --disable pwquality pwhistory unix --package --force


#########################################################################
# 4) Remove games user
#########################################################################
id -u games &>/dev/null && userdel -r games || true

#########################################################################
# 5) Permissions
#########################################################################
touch /etc/cron.allow /etc/at.allow
chmod 644 /etc/cron.allow /etc/at.allow
chown root:root /boot/grub/grub.cfg
chmod u-x,go-rwx /boot/grub/grub.cfg
chown root:root /etc/crontab
chmod og-rwx /etc/crontab
chown root:root /etc/crontab /etc/cron.*
chmod 700 /etc/cron.*
chown root:root /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config.d/*
chmod 600 /etc/ssh/sshd_config.d/*
chmod 600 /boot/grub/grub.cfg
chmod 640 /etc/cron.allow
chmod 640 /etc/shadow
chmod 640 /etc/shadow-
chmod 640 /etc/gshadow
chmod 640 /etc/gshadow-
chmod 700 /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules
find /var/log -type f -exec chmod 640 {} \;
find /var/log -type d -exec chmod 750 {} \;
grep -Pq -- '^daemon\b' /etc/group && l_group="daemon" || l_group="root"
[ ! -e "/etc/at.allow" ] && touch /etc/at.allow
chown root:"$l_group" /etc/at.allow
chmod u-x,g-wx,o-rwx /etc/at.allow
[ -e "/etc/at.deny" ] && chown root:"$l_group" /etc/at.deny
[ -e "/etc/at.deny" ] && chmod u-x,g-wx,o-rwx /etc/at.deny

#########################################################################
# 6) system.conf options
#########################################################################
CONF=/etc/systemd/system.conf
if grep -qE '^\s*CtrlAltDelBurstAction=' "$CONF"; then
  sed -ri 's|^\s*CtrlAltDelBurstAction\s*=.*|CtrlAltDelBurstAction=none|' "$CONF"
else
  echo 'CtrlAltDelBurstAction=none' >> "$CONF"
fi
#########################################################################
# 7) hosts configuration
#########################################################################
echo "all:all" > /etc/hosts.deny
printf '%s\n' "$HOSTS_ALLOW_TEXT" > /etc/hosts.allow

#########################################################################
# 8) GRUB configuration
#########################################################################
cat >/etc/default/grub <<EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR="$(lsb_release -i -s 2>/dev/null || echo Debian)"
GRUB_CMDLINE_LINUX_DEFAULT="apparmor=1 security=apparmor audit=1 audit_backlog_limit=8192"
GRUB_CMDLINE_LINUX="audit=1"
GRUB_DISABLE_RECOVERY="true"
EOF

cat >/etc/default/grub.d/99-hardening.cfg <<'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR="$(lsb_release -i -s 2>/dev/null || echo Debian)"
GRUB_CMDLINE_LINUX_DEFAULT="apparmor=1 security=apparmor audit=1 audit_backlog_limit=8192"
GRUB_CMDLINE_LINUX="audit=1"
GRUB_DISABLE_RECOVERY="true"
EOF

update-grub

#########################################################################
# 9) SSHD configuration
#########################################################################
cat >/etc/ssh/sshd_config <<'EOF'
Ciphers -3des-cbc,aes128-cbc,aes192-cbc,aes256-cbc,chacha20-poly1305@openssh.com
LoginGraceTime 60
PermitRootLogin no
IgnoreUserKnownHosts yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
PermitUserEnvironment no
Banner /etc/issue.net
AcceptEnv LANG LC_*
Subsystem       sftp    /usr/lib/openssh/sftp-server
Protocol 2
AllowGroups admins
ClientAliveInterval 15
ClientAliveCountMax 3
IgnoreRhosts yes
HostbasedAuthentication no
MACs -hmac-md5,hmac-md5-96,hmac-ripemd160,hmac-sha1,hmac-sha1-96,umac-64@openssh.com,umac-128@openssh.com,hmac-md5-etm@openssh.com,hmac-md5-96-etm@openssh.com,hmac-ripemd160-etm@openssh.com,hmac-sha1-etm@openssh.com,hmac-sha1-96-etm@openssh.com,umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
MaxStartups 10:30:60
MaxAuthTries 4
DisableForwarding yes
Port 22345
EOF
systemctl reload ssh && systemctl restart ssh

#########################################################################
# 10) security configuration
#########################################################################
cat >/etc/security/limits.conf <<'EOF'
* hard core 0
* hard maxlogins 2
* hard nproc 500
EOF
grep -E '^[#]*[[:space:]]*deny[[:space:]]*=' /etc/security/faillock.conf && \
sed -i 's/^[#]*[[:space:]]*deny[[:space:]]*=.*/deny=5/' /etc/security/faillock.conf \
|| echo 'deny=5' >> /etc/security/faillock.conf

grep -E '^[#]*[[:space:]]*even_deny_root[[:space:]]*' /etc/security/faillock.conf && \
sed -i 's/^[#]*[[:space:]]*even_deny_root[[:space:]]*/even_deny_root/' /etc/security/faillock.conf \
|| echo 'even_deny_root' >> /etc/security/faillock.conf

grep -E '^[#]*[[:space:]]*root_unlock_time[[:space:]]*=' /etc/security/faillock.conf && \
sed -i 's/^[#]*[[:space:]]*root_unlock_time[[:space:]]*=.*/root_unlock_time=60/' /etc/security/faillock.conf \
|| echo 'root_unlock_time=60' >> /etc/security/faillock.conf

grep -E '^[#]*[[:space:]]*unlock_time[[:space:]]*=' /etc/security/faillock.conf && \
sed -i 's/^[#]*[[:space:]]*unlock_time[[:space:]]*=.*/unlock_time=900/' /etc/security/faillock.conf \
|| echo 'unlock_time=900' >> /etc/security/faillock.conf

grep -E '^\s*[#]*\s*maxrepeat\s*=\s*.*'  /etc/security/pwquality.conf && \
sed -i 's/^\s*[#]*\s*maxrepeat\s*=\s*.*/maxrepeat=3/' /etc/security/pwquality.conf \
|| echo 'maxrepeat=3' >> /etc/security/pwquality.conf

grep -E '^\s*[#]*\s*minlen\s*=\s*.*'  /etc/security/pwquality.conf && \
sed -i 's/^\s*[#]*\s*minlen\s*=\s*.*/minlen=8/' /etc/security/pwquality.conf \
|| echo 'minlen=8' >> /etc/security/pwquality.conf

grep -E '^\s*[#]*\s*difok\s*=\s*.*'  /etc/security/pwquality.conf && \
sed -i 's/^\s*[#]*\s*difok\s*=\s*.*/difok=2/' /etc/security/pwquality.conf \
|| echo 'difok=2' >> /etc/security/pwquality.conf

grep -E '^\s*[#]*\s*maxsequence\s*=\s*.*'  /etc/security/pwquality.conf && \
sed -i 's/^\s*[#]*\s*maxsequence\s*=\s*.*/maxsequence=3/' /etc/security/pwquality.conf \
|| echo 'maxsequence=3' >> /etc/security/pwquality.conf

grep -E '^\s*[#]*\s*minclass\s*=\s*.*'  /etc/security/pwquality.conf && \
sed -i 's/^\s*[#]*\s*minclass\s*=\s*.*/minclass=4/' /etc/security/pwquality.conf \
|| echo 'minclass=4' >> /etc/security/pwquality.conf

#########################################################################
# 11) fstab configuration
#########################################################################
sed -ri 's|^(\S+\s+/boot\s+)\S+.*|\1ext4 nodev,nosuid,noexec,ro 0 2|' /etc/fstab
sed -ri 's|^(\S+\s+/home\s+)\S+.*|\1ext4 defaults,nodev,nosuid,noexec,usrquota 0 0|' /etc/fstab
grep -E ' /tmp .*noexec'  /etc/fstab || sed -i -E 's/^(.+[[:space:]]+\/tmp[[:space:]]+.+[[:space:]]+.+)([[:space:]]+.+[[:space:]]+.+)/\1,noexec\2/' /etc/fstab
grep -E ' /var/tmp .*noexec'  /etc/fstab || sed -i -E 's/^(.+[[:space:]]+\/var\/tmp[[:space:]]+.+[[:space:]]+.+)([[:space:]]+.+[[:space:]]+.+)/\1,noexec\2/' /etc/fstab

#########################################################################
# 12) profile configuration
#########################################################################
if grep -qE '^\s*TMOUT=' /etc/profile; then
  sed -ri 's|^\s*TMOUT=.*|TMOUT=600|' /etc/profile
else
  echo 'TMOUT=600' >> /etc/profile
fi
if grep -qE '^\s*HISTSIZE=' /etc/profile; then
  sed -ri 's|^\s*HISTSIZE=.*|HISTSIZE=1000|' /etc/profile
else
  echo 'HISTSIZE=1000' >> /etc/profile
fi

grep -qE '^\s*export\s+TMOUT\b' /etc/profile || echo 'export TMOUT' >> /etc/profile
grep -qE '^\s*readonly\s+TMOUT\b' /etc/profile || echo 'readonly TMOUT' >> /etc/profile
grep -qE '^\s*export\s+HISTSIZE\b' /etc/profile || echo 'export HISTSIZE' >> /etc/profile

#########################################################################
# 13) auditd configuration
#########################################################################
sed -ri 's|^\s*max_log_file\s*=.*|max_log_file = 10|' /etc/audit/auditd.conf

grep 'max_log_file_action'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*max_log_file_action .*/max_log_file_action = keep_logs/' /etc/audit/auditd.conf \
|| echo 'max_log_file_action = keep_logs' >> /etc/audit/auditd.conf

grep 'disk_full_action'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*disk_full_action .*/disk_full_action = single/' /etc/audit/auditd.conf \
|| echo 'disk_full_action = single' >> /etc/audit/auditd.conf

grep 'disk_error_action'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*disk_error_action .*/disk_error_action = syslog/' /etc/audit/auditd.conf \
|| echo 'disk_error_action = syslog' >> /etc/audit/auditd.conf

grep -E '^[^_]*admin_space_left_action[^_]'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*admin_space_left_action .*/admin_space_left_action = single/' /etc/audit/auditd.conf \
|| echo 'admin_space_left_action = single' >> /etc/audit/auditd.conf

grep -E '^[^_]*space_left_action[^_]'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*space_left_action .*/space_left_action = email/' /etc/audit/auditd.conf \
|| echo 'space_left_action = email' >> /etc/audit/auditd.conf

grep -E '^[^_]*admin_space_left[^_]'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*admin_space_left .*/admin_space_left = 1/' /etc/audit/auditd.conf \
|| echo 'admin_space_left = 1' >> /etc/audit/auditd.conf

grep -E '^[^_]*space_left[^_]'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*space_left .*/space_left = 500/' /etc/audit/auditd.conf \
|| echo 'space_left = 500' >> /etc/audit/auditd.conf

grep -E '^[^_]*action_mail_acct[^_]'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*action_mail_acct.*/action_mail_acct = $SUPPORT_MAIL/' /etc/audit/auditd.conf \
|| echo 'action_mail_acct = $SUPPORT_MAIL' >> /etc/audit/auditd.conf

find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) -exec chmod u-x,g-wx,o-rwx {} +
systemctl restart auditd || true

#########################################################################
# 14) audit rules.d
#########################################################################
UID_MIN=$(awk '/^[[:space:]]*UID_MIN[[:space:]]+[0-9]+/ {print $2}' /etc/login.defs)

if [ -n "$UID_MIN" ]; then
cat > /etc/audit/rules.d/50-kernel_modules.rules <<EOF
-a always,exit -F arch=b64 -S init_module,finit_module,delete_module,create_module,query_module -F auid>=$UID_MIN -F auid!=unset -k kernel_modules
-a always,exit -F path=/usr/bin/kmod -F perm=x -F auid>=$UID_MIN -F auid!=unset -k kernel_modules
EOF

cat > /etc/audit/rules.d/50-usermod.rules <<EOF
-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=$UID_MIN -F auid!=unset -k usermod
EOF

cat > /etc/audit/rules.d/50-perm_chng.rules <<EOF
-a always,exit -F path=/usr/bin/chacl   -F perm=x -F auid>=$UID_MIN -F auid!=unset -k perm_chng
-a always,exit -F path=/usr/bin/setfacl -F perm=x -F auid>=$UID_MIN -F auid!=unset -k perm_chng
-a always,exit -F path=/usr/bin/chcon   -F perm=x -F auid>=$UID_MIN -F auid!=unset -k perm_chng
EOF

cat > /etc/audit/rules.d/50-MAC-policy.rules <<'EOF'
-w /etc/apparmor/   -p wa -k MAC-policy
-w /etc/apparmor.d/ -p wa -k MAC-policy
EOF

cat > /etc/audit/rules.d/50-delete.rules <<EOF
-a always,exit -F arch=b64 -S rename,unlink,unlinkat,renameat -F auid>=$UID_MIN -F auid!=unset -F key=delete
-a always,exit -F arch=b32 -S rename,unlink,unlinkat,renameat -F auid>=$UID_MIN -F auid!=unset -F key=delete
EOF

cat > /etc/audit/rules.d/50-session.rules <<'EOF'
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session
EOF

cat > /etc/audit/rules.d/50-login.rules <<'EOF'
-w /var/log/lastlog  -p wa -k logins
-w /var/run/faillock -p wa -k logins
EOF

cat > /etc/audit/rules.d/50-mounts.rules <<EOF
-a always,exit -F arch=b32 -S mount -F auid>=$UID_MIN -F auid!=unset -k mounts
-a always,exit -F arch=b64 -S mount -F auid>=$UID_MIN -F auid!=unset -k mounts
EOF

cat > /etc/audit/rules.d/50-perm_mod.rules <<EOF
-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=$UID_MIN -F auid!=unset -F key=perm_mod
-a always,exit -F arch=b64 -S chown,fchown,lchown,fchownat -F auid>=$UID_MIN -F auid!=unset -F key=perm_mod
-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=$UID_MIN -F auid!=unset -F key=perm_mod
-a always,exit -F arch=b32 -S chown,fchown,lchown,fchownat -F auid>=$UID_MIN -F auid!=unset -F key=perm_mod
-a always,exit -F arch=b64 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=$UID_MIN -F auid!=unset -F key=perm_mod
-a always,exit -F arch=b32 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=$UID_MIN -F auid!=unset -F key=perm_mod
EOF

cat > /etc/audit/rules.d/50-identity.rules <<'EOF'
-w /etc/group            -p wa -k identity
-w /etc/passwd           -p wa -k identity
-w /etc/gshadow          -p wa -k identity
-w /etc/shadow           -p wa -k identity
-w /etc/security/opasswd -p wa -k identity
-w /etc/nsswitch.conf    -p wa -k identity
-w /etc/pam.conf         -p wa -k identity
-w /etc/pam.d/           -p wa -k identity
EOF

cat > /etc/audit/rules.d/50-access.rules <<EOF
-a always,exit -F arch=b64 -S creat,open,openat,truncate,ftruncate -F exit=-EACCES -F auid>=$UID_MIN -F auid!=unset -k access
-a always,exit -F arch=b64 -S creat,open,openat,truncate,ftruncate -F exit=-EPERM  -F auid>=$UID_MIN -F auid!=unset -k access
-a always,exit -F arch=b32 -S creat,open,openat,truncate,ftruncate -F exit=-EACCES -F auid>=$UID_MIN -F auid!=unset -k access
-a always,exit -F arch=b32 -S creat,open,openat,truncate,ftruncate -F exit=-EPERM  -F auid>=$UID_MIN -F auid!=unset -k access
EOF

cat > /etc/audit/rules.d/50-system_locale.rules <<'EOF'
-a always,exit -F arch=b64 -S sethostname,setdomainname -k system-locale
-a always,exit -F arch=b32 -S sethostname,setdomainname -k system-locale
-w /etc/issue     -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts     -p wa -k system-locale
-w /etc/networks  -p wa -k system-locale
-w /etc/network/  -p wa -k system-locale
-w /etc/netplan/  -p wa -k system-locale
EOF

cat > /etc/audit/rules.d/50-time-change.rules <<'EOF'
-a always,exit -F arch=b64 -S adjtimex,settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex,settimeofday -k time-change
-a always,exit -F arch=b64 -S clock_settime -F a0=0x0 -k time-change
-a always,exit -F arch=b32 -S clock_settime -F a0=0x0 -k time-change
-w /etc/localtime -p wa -k time-change
EOF

cat > /etc/audit/rules.d/50-user_emulation.rules <<'EOF'
-a always,exit -F arch=b64 -C euid!=uid -F auid!=unset -S execve -k user_emulation
-a always,exit -F arch=b32 -C euid!=uid -F auid!=unset -S execve -k user_emulation
EOF

cat > /etc/audit/rules.d/50-scope.rules <<'EOF'
-w /etc/sudoers   -p wa -k scope
-w /etc/sudoers.d -p wa -k scope
EOF
fi

augenrules --check

systemctl restart auditd
#########################################################################
# 15) kernel modules
#########################################################################
# squashfs is used by Ubuntu Snap packages, so we dont't disable them.
# overlayfs  is used by Docker/containerd/Kubernetes and “live-boot” tools, so we dont't disable them.
modules=(cramfs freevxfs hfs hfsplus jffs2 udf usb-storage afs dccp tipc rds sctp)
for module in "${modules[@]}"; do
        echo "install ${module} /bin/false" | sudo tee /etc/modprobe.d/${module}.conf
        echo "blacklist ${module}" | sudo tee -a /etc/modprobe.d/${module}.conf
        sudo modprobe -r ${module} 2>/dev/null
        sudo rmmod ${module} 2>/dev/null
done

#########################################################################
# 16) purge packages
#########################################################################
apt purge -y telnet
apt purge -y inetutils-telnet
apt purge -y ftp
apt purge -y tnftp
apt purge -y prelink

#########################################################################
# 17) root and sudo configs
#########################################################################
touch /root/.bash_profile
grep -Eq '^\s*umask\s+[0-9]+' /root/.bashrc && sed -i 's/^umask\s\+[0-9]\+$/umask 0077/' /root/.bashrc \
|| echo 'umask 0077' >> /root/.bashrc
grep -Eq '^\s*umask\s+[0-9]+' /root/.bash_profile && sed -i 's/^umask\s\+[0-9]\+$/umask 0077/' /root/.bash_profile \
|| echo 'umask 0077' >> /root/.bash_profile

if ! grep -Rqs '^[[:space:]]*Defaults.*logfile=' /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
  cat > /etc/sudoers.d/10-sudo-logfile <<'EOF'
Defaults use_pty
Defaults logfile="/var/log/sudo.log"
EOF
  chmod 440 /etc/sudoers.d/10-sudo-logfile
  visudo -cf /etc/sudoers.d/10-sudo-logfile  # valida sintaxis
fi

SUDO_LOG_FILE=$(
  { grep -Rhs '^[[:space:]]*Defaults.*logfile=' /etc/sudoers /etc/sudoers.d/* 2>/dev/null || true; } |
  sed -E 's/.*logfile="?([^", ]+).*/\1/' |
  head -n1
)

: "${SUDO_LOG_FILE:=/var/log/sudo.log}"

if ! grep -R -qE "(-w[[:space:]]*$SUDO_LOG_FILE\b)|(-F[[:space:]]+path=$SUDO_LOG_FILE\b)" /etc/audit/rules.d ; then
  printf -- '-w %s -p wa -k sudo_log_file\n' "$SUDO_LOG_FILE" > /etc/audit/rules.d/50-sudo.rules
fi

#########################################################################
# 18) postfix configuration
#########################################################################
grep -E '^myorigin'  /etc/postfix/main.cf && sed -i 's/^[#[:space:]]*myorigin.*/myorigin = $POSTFIX_DOMAIN/' /etc/postfix/main.cf \
|| echo 'myorigin = $POSTFIX_DOMAIN' >> /etc/postfix/main.cf
grep -E '^relay'  /etc/postfix/main.cf && sed -i 's/^[#[:space:]]*relay.*/relay = [$POSTFIX_IP]:25/' /etc/postfix/main.cf \
|| echo 'relay = [$POSTFIX_IP]:25' >> /etc/postfix/main.cf
grep -E '^myhostname'  /etc/postfix/main.cf && sed -i "s/^[#[:space:]]*myhostname.*/myhostname = ${HOSTNAME}.$POSTFIX_DOMAIN/" /etc/postfix/main.cf \
|| echo "myhostname = ${HOSTNAME}.$POSTFIX_DOMAIN" >> /etc/postfix/main.cf

#########################################################################
# 19) systemd-timesyncd
#########################################################################
systemctl unmask systemd-timesyncd.service
systemctl --now enable systemd-timesyncd.service
grep -E '^[#]*NTP[[:space:]]*=' /etc/systemd/timesyncd.conf && sed -i 's/^[#]*NTP[[:space:]]*=/NTP=hora.roa.es/' /etc/systemd/timesyncd.conf \
|| echo 'NTP=hora.roa.es' >> /etc/systemd/timesyncd.conf

grep -E '^[#]*FallbackNTP[[:space:]]*=' /etc/systemd/timesyncd.conf \
&& sed -i 's/^[#]*FallbackNTP[[:space:]]*=/FallbackNTP=ntp.ubuntu.com/' /etc/systemd/timesyncd.conf \
|| echo 'NTP=ntp.ubuntu.com' >> /etc/systemd/timesyncd.conf

#########################################################################
# 20) /var/log permissions
#########################################################################
tee /etc/logrotate.d/wtmp >/dev/null <<'EOF'
/var/log/wtmp {
  monthly
  missingok
  create 0640 root utmp
  rotate 1
}
EOF

tee /etc/logrotate.d/btmp >/dev/null <<'EOF'
/var/log/btmp {
  monthly
  missingok
  create 0600 root utmp
  rotate 1
}
EOF
tee /etc/logrotate.d/apt >/dev/null <<'EOF'
/var/log/apt/term.log {
  rotate 52
  weekly
  compress
  missingok
  notifempty
  create 0640 root adm
}

/var/log/apt/history.log {
  rotate 52
  weekly
  compress
  missingok
  notifempty
  create 0640 root adm
}
EOF
tee /etc/tmpfiles.d/zz-log-perms.conf >/dev/null <<'EOF'
z /var/log/wtmp    0640 root utmp - -
z /var/log/lastlog 0640 root utmp - -
z /var/log/btmp    0600 root utmp - -
EOF
cat >/etc/tmpfiles.d/99-apt-logs.conf <<'EOF'
f /var/log/apt/history.log 0640 root adm -
f /var/log/apt/eipp.log.xz 0640 root adm -
EOF
sed -i 's/create 644 root root/create 640 root adm/' /etc/logrotate.d/alternatives
sed -i 's/create 644 root root/create 640 root adm/' /etc/logrotate.d/dpkg
sed -i 's/create 0644 root root/create 0640 root adm/' /etc/logrotate.d/ubuntu-pro-client

sed -i -E '/^[[:space:]]*\/var\/log\/wtmp[[:space:]]*\{/,/^[[:space:]]*\}/d' /etc/logrotate.conf
sed -i -E '/^[[:space:]]*\/var\/log\/btmp[[:space:]]*\{/,/^[[:space:]]*\}/d' /etc/logrotate.conf
systemd-tmpfiles --create
logrotate -f /etc/logrotate.conf

#########################################################################
# 21) sysctl configuration
#########################################################################
printf "%s\n" "kernel.randomize_va_space = 2" >> /etc/sysctl.d/60-kernel_sysctl.conf
tee /etc/sysctl.d/60-icmp-redirects.conf >/dev/null <<'EOF'
# Deshabilitar ICMP redirects (IPv4/IPv6)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
EOF
cat > /etc/sysctl.d/60-netipv6_sysctl.conf <<'EOF'
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
EOF
printf '%s\n' "net.ipv4.conf.all.log_martians = 1" "net.ipv4.conf.default.log_martians = 1"\
              "net.ipv4.route.flush=1" "net.ipv4.conf.default.send_redirects=0"\
              "net.ipv4.conf.all.send_redirects=0" "net.ipv4.conf.all.secure_redirects=0"\
              "net.ipv4.conf.all.secure_redirects=0" "net.ipv4.conf.default.secure_redirects=0"\
              "net.ipv4.conf.all.rp_filter=1" "net.ipv4.conf.default.rp_filter=1"\
              "net.ipv4.conf.all.accept_source_route=0" "net.ipv4.conf.default.accept_source_route=0"\
              > /etc/sysctl.d/60-netipv4_sysctl.conf
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv4.route.flush=1
sysctl -w net.ipv4.conf.default.send_redirects=0
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv4.conf.default.accept_source_route=0
sysctl -w net.ipv6.conf.all.accept_source_route=0
sysctl -w net.ipv6.conf.default.accept_source_route=0
printf "%s\n" "fs.suid_dumpable = 0" > /etc/sysctl.d/60-fs_sysctl.conf

sysctl -w fs.suid_dumpable=0
sysctl -w net.ipv6.conf.all.accept_ra=0
sysctl -w net.ipv6.conf.default.accept_ra=0
sysctl -w net.ipv6.route.flush=1
sysctl --system

#########################################################################
# 22) journal configuration
#########################################################################
systemctl unmask systemd-journal-upload.service
systemctl --now enable systemd-journal-upload.service

grep -E '^\s*\t*#*\s*\t*MaxFileSec\s*=' /etc/systemd/journald.conf && \
sed -i -E 's/^\s*\t*#*\s*\t*MaxFileSec\s*=.*/MaxFileSec=1month/' /etc/systemd/journald.conf \
|| echo 'MaxFileSec=1month' >> /etc/systemd/journald.conf

grep -E '^\s*\t*#*\s*\t*RuntimeKeepFree\s*=' /etc/systemd/journald.conf && \
sed -i -E 's/^\s*\t*#*\s*\t*RuntimeKeepFree\s*=.*/RuntimeKeepFree=50M/' /etc/systemd/journald.conf \
|| echo 'RuntimeKeepFree=50M' >> /etc/systemd/journald.conf

grep -E '^\s*\t*#*\s*\t*RuntimeMaxUse\s*=' /etc/systemd/journald.conf && \
sed -i -E 's/^\s*\t*#*\s*\t*RuntimeMaxUse\s*=.*/RuntimeMaxUse=200M/' /etc/systemd/journald.conf \
|| echo 'RuntimeMaxUse=200M' >> /etc/systemd/journald.conf

grep -E '^\s*\t*#*\s*\t*SystemKeepFree\s*=' /etc/systemd/journald.conf && \
sed -i -E 's/^\s*\t*#*\s*\t*SystemKeepFree\s*=.*/SystemKeepFree=500M/' /etc/systemd/journald.conf \
|| echo 'SystemKeepFree=500M' >> /etc/systemd/journald.conf

grep -E '^\s*\t*#*\s*\t*SystemMaxUse\s*=' /etc/systemd/journald.conf && \
sed -i -E 's/^\s*\t*#*\s*\t*SystemMaxUse\s*=.*/SystemMaxUse=1G/' /etc/systemd/journald.conf \
|| echo 'SystemMaxUse=1G' >> /etc/systemd/journald.conf

systemctl reload-or-restart systemd-journald

#########################################################################
# 23) /etc/passwd and /etc/shadow
#########################################################################
useradd -D -f 45
awk -F: 'NR==FNR { if ($3>=1000 && $1!="nobody") u[$1]=1; next }
          ($1 in u) && ($2 ~ /^\$/) && ($7 > 45 || $7 < 0) { print $1 ":" $7 }' \
    /etc/passwd /etc/shadow

awk -F: 'NR==FNR { if ($3>=1000 && $1!="nobody") u[$1]=1; next }
          ($1 in u) && ($2 ~ /^\$/) && ($7 > 45 || $7 < 0) { print $1 }' \
    /etc/passwd /etc/shadow \
 | xargs -r -n1 chage --inactive 45

awk -F: 'NR==FNR { if($3>=1000 && $1!="nobody") u[$1]=1; next }
          ($1 in u) && ($2 ~ /^\$/) && ($4 < 1) { print $1 }' \
    /etc/passwd /etc/shadow | xargs -r -n1 chage --mindays 1

awk -F: '($2 ~ /^\$/) && ($5 > 365 || $5 < 1) {print $1}' /etc/shadow \
 | xargs -r -n1 chage --maxdays 365

awk -F: '($2~/^\$/) && ($4 < 1) {print $1 ":" $4}' /etc/shadow || true

#########################################################################
# 24) /etc/login.defs
#########################################################################
if grep -qE '^\s*PASS_MIN_DAYS\b' /etc/login.defs; then
  sed -ri 's/^\s*PASS_MIN_DAYS\b.*/PASS_MIN_DAYS 1/' /etc/login.defs
else
  echo 'PASS_MIN_DAYS 1' >> /etc/login.defs
fi

if grep -qE '^\s*PASS_MAX_DAYS\b' /etc/login.defs; then
  sed -ri 's/^\s*PASS_MAX_DAYS\b.*/PASS_MAX_DAYS 365/' /etc/login.defs
else
  echo 'PASS_MAX_DAYS 365' >> /etc/login.defs
fi

#########################################################################
# 25) /etc/issue and /etc/issue.net
#########################################################################
printf '%s\n' "$AUTHORIZED_TEXT" > /etc/issue
printf '%s\n' "$AUTHORIZED_TEXT" > /etc/issue.net

#########################################################################
# 26) rest of configurations
#########################################################################
# Aide
printf "%s\n" "# Audit Tools" "$(readlink -f /sbin/auditctl) p+i+n+u+g+s+b+acl+xattrs+sha512" "$(readlink -f /sbin/auditd)\
p+i+n+u+g+s+b+acl+xattrs+sha512" "$(readlink -f /sbin/ausearch) p+i+n+u+g+s+b+acl+xattrs+sha512" "$(readlink -f /sbin/aureport)\
p+i+n+u+g+s+b+acl+xattrs+sha512" "$(readlink -f /sbin/autrace) p+i+n+u+g+s+b+acl+xattrs+sha512" "$(readlink -f /sbin/augenrules)\
p+i+n+u+g+s+b+acl+xattrs+sha512" >> /etc/aide/aide.conf
# /etc/rsyslog
cat > /etc/rsyslog.d/60-rsyslog.conf <<'EOF'
$FileCreateMode 0640
*.* action(type="omfwd" target="loghost.example.com" port="514" protocol="tcp" action.resumeRetryCount="100" queue.type="LinkedList" queue.size="1000")
EOF
systemctl reload-or-restart rsyslog
# apport
sed -i -E 's/^\s*\t*enabled\s*=.*/enabled=0/' /etc/default/apport
systemctl disable apport.service
# /etc/audit/rules.d
echo "-e 2" > /etc/audit/rules.d/99-finalize.rules
augenrules --load
# remount partitions
mount -o remount /tmp/
mount -o remount /home/
mount -o remount /boot/
mount -o remount /var/tmp/