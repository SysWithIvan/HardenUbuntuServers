#!/usr/bin/env bash
# ========================================================================
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