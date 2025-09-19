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

sed -ri 's|^(\S+\s+/boot\s+)\S+.*|\1ext4 nodev,nosuid,noexec,ro 0 2|' /etc/fstab
sed -ri 's|^(\S+\s+/home\s+)\S+.*|\1ext4 defaults,nodev,nosuid,noexec,usrquota 0 0|' /etc/fstab
grep -E ' /tmp .*noexec'  /etc/fstab || sed -i -E 's/^(.+[[:space:]]+\/tmp[[:space:]]+.+[[:space:]]+.+)([[:space:]]+.+[[:space:]]+.+)/\1,noexec\2/' /etc/fstab
grep -E ' /var/tmp .*noexec'  /etc/fstab || sed -i -E 's/^(.+[[:space:]]+\/var\/tmp[[:space:]]+.+[[:space:]]+.+)([[:space:]]+.+[[:space:]]+.+)/\1,noexec\2/' /etc/fstab