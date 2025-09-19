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