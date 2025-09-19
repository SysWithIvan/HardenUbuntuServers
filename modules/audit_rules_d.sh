#!/usr/bin/env bash
# ========================================================================
# Tested on:     Ubuntu 24.04 LTS
# Author:        Iván Texenery Díaz García (ivantexenery@gmail.com)
# Version:       1.0.0 (2025-09-15)
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2025 Iván Texenery Díaz García
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version. See the LICENSE file for details.       
# =======================================================================

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