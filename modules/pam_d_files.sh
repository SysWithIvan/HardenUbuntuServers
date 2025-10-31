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

grep -Eq '^[[:space:]]*auth[[:space:]]*required[[:space:]]*pam_wheel\.so[[:space:]]*use_uid[[:space:]]*group[[:space:]]*=[[:space:]]*.+$' /etc/pam.d/su && \
sed -E -i 's/^[[:space:]]*auth[[:space:]]*required[[:space:]]*pam_wheel\.so[[:space:]]*use_uid[[:space:]]*group[[:space:]]*=[[:space:]]*.+$/auth required pam_wheel.so use_uid group=admins/' /etc/pam.d/su || \
echo 'auth required pam_wheel.so use_uid group=admins' >> /etc/pam.d/su

cat >/etc/pam.d/common-password <<'EOF'
# here are the per-package modules (the "Primary" block)
password        requisite                       pam_pwquality.so try_first_pass retry=3 minlen=8 minclass=3 difok=3
password        requisite                       pam_pwhistory.so remember=24 use_authtok enforce_for_root
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
