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

useradd -D -f 45
awk -F: 'NR==FNR { if ($3>=1000 && $1!="nobody") u[$1]=1; next }
          ($1 in u) && ($2 ~ /^\$/) && ($7 > 45 || $7 < 0) { print $1 ":" $7 }' \
    /etc/passwd /etc/shadow

awk -F: 'NR==FNR { if ($3>=1000 && $1!="nobody") u[$1]=1; next }
          ($1 in u) && ($2 ~ /^\$/) && ($7 > 45 || $7 < 0) { print $1 }' \
    /etc/passwd /etc/shadow \
 | xargs -r -n1 chage --inactive 45

awk -F: 'NR==FNR { if($3>=1000 && $1!="nobody") u[$1]=1; next }
          ($1 in u) && ($2 ~ /^\$/) && ($4 < 1) { print $1 }' \
    /etc/passwd /etc/shadow | xargs -r -n1 chage --mindays 1

awk -F: '($2 ~ /^\$/) && ($5 > 365 || $5 < 1) {print $1}' /etc/shadow \
 | xargs -r -n1 chage --maxdays 365

awk -F: '($2~/^\$/) && ($4 < 1) {print $1 ":" $4}' /etc/shadow || true