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