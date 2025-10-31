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

apt-get update -y || true
apt-get install -y libpam-pwquality
apt-get install aide aide-common -y
apt-get install -y audispd-plugins
apt-get install -y systemd-timesyncd
apt-get install -y systemd-journal-remote
apt-get install -y systemd-coredump
apt-get install -y apparmor apparmor-utils