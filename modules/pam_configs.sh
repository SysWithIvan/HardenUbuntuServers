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