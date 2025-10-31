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