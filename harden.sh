#!/usr/bin/env bash
# ========================================================================
# Script:        harden.sh
# Description:   This script has been designed to Harden Ubuntu Linux servers 
#                to align with the CIS Benchmarks for Ubuntu.
# Usage:         chmod +x harden.sh; sudo ./harden.sh
# Tested on:     Ubuntu 24.04 LTS, Ubuntu 22.04 LTS
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
export DEBIAN_FRONTEND=noninteractive
export AUTHORIZED_TEXT="
Put something useful to warn about the consequences of a bad use of the systems
"
export HOSTS_ALLOW_TEXT="
sshd: --> put networks which from can access using ssh login 
"
export SUPPORT_MAIL="Put the mail which will receive the alerts, such as the space left on device alert."
export POSTFIX_DOMAIN="mydomain.net"
export POSTFIX_IP="my_relay_ip"

#########################################################################
# 0) Establish system language
#########################################################################
sudo sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
sudo update-locale LANG=en_US.UTF-8 LC_MESSAGES=en_US.UTF-8 LANGUAGE=en_US:en
unset LC_ALL
. /etc/default/locale

#########################################################################
# 1) Install necesary packages
#########################################################################
./modules/install_necessary_packages.sh

#########################################################################
# 2) Configurate pamd.d files
#########################################################################
./modules/pam_d_files.sh

#########################################################################
# 3) Configurate pam configs
#########################################################################
./modules/pam_configs.sh

#########################################################################
# 4) Remove games user
#########################################################################
./modules/games_user.sh

#########################################################################
# 5) Permissions
#########################################################################
./modules/permissions.sh

#########################################################################
# 6) system.conf options
#########################################################################
./modules/system_conf.sh

#########################################################################
# 7) hosts configuration
#########################################################################
./modules/hosts.sh

#########################################################################
# 8) GRUB configuration
#########################################################################
./modules/grub.sh

#########################################################################
# 9) SSHD configuration
#########################################################################
./modules/sshd.sh

#########################################################################
# 10) security configuration
#########################################################################
./modules/security.sh

#########################################################################
# 11) fstab configuration
#########################################################################
./modules/fstab.sh

#########################################################################
# 12) profile configuration
#########################################################################
./modules/profile.sh

#########################################################################
# 13) auditd configuration
#########################################################################
./modules/auditd_conf.sh

#########################################################################
# 14) audit rules.d
#########################################################################
./modules/audit_rules_d.sh

#########################################################################
# 15) kernel modules
#########################################################################
./modules/kernel_modules.sh

#########################################################################
# 16) purge packages
#########################################################################
./modules/purge_unnecesary_packages.sh

#########################################################################
# 17) root and sudo configs
#########################################################################
./modules/sudo.sh

#########################################################################
# 18) postfix configuration
#########################################################################
./modules/postfix.sh

#########################################################################
# 19) systemd-timesyncd
#########################################################################
./modules/systemd-timesyncd.sh

#########################################################################
# 20) /var/log permissions
#########################################################################
./modules/var_log_permissions.sh

#########################################################################
# 21) sysctl configuration
#########################################################################
./modules/sysctl.sh

#########################################################################
# 22) journal configuration
#########################################################################
./modules/journal.sh

#########################################################################
# 23) /etc/passwd and /etc/shadow
#########################################################################
./modules/passwd_and_shadow.sh

#########################################################################
# 24) /etc/login.defs
#########################################################################
./modules/login.sh

#########################################################################
# 25) /etc/issue and /etc/issue.net
#########################################################################
./modules/issue.sh

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