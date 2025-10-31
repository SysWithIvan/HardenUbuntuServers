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