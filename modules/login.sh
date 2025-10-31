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

if grep -qE '^\s*PASS_MIN_DAYS\b' /etc/login.defs; then
  sed -ri 's/^\s*PASS_MIN_DAYS\b.*/PASS_MIN_DAYS 1/' /etc/login.defs
else
  echo 'PASS_MIN_DAYS 1' >> /etc/login.defs
fi

if grep -qE '^\s*PASS_MAX_DAYS\b' /etc/login.defs; then
  sed -ri 's/^\s*PASS_MAX_DAYS\b.*/PASS_MAX_DAYS 365/' /etc/login.defs
else
  echo 'PASS_MAX_DAYS 365' >> /etc/login.defs
fi