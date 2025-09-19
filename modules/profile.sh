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

if grep -qE '^\s*TMOUT=' /etc/profile; then
  sed -ri 's|^\s*TMOUT=.*|TMOUT=600|' /etc/profile
else
  echo 'TMOUT=600' >> /etc/profile
fi
if grep -qE '^\s*HISTSIZE=' /etc/profile; then
  sed -ri 's|^\s*HISTSIZE=.*|HISTSIZE=1000|' /etc/profile
else
  echo 'HISTSIZE=1000' >> /etc/profile
fi

grep -qE '^\s*export\s+TMOUT\b' /etc/profile || echo 'export TMOUT' >> /etc/profile
grep -qE '^\s*readonly\s+TMOUT\b' /etc/profile || echo 'readonly TMOUT' >> /etc/profile
grep -qE '^\s*export\s+HISTSIZE\b' /etc/profile || echo 'export HISTSIZE' >> /etc/profile