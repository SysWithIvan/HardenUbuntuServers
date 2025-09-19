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

grep -E '^myorigin'  /etc/postfix/main.cf && sed -i 's/^[#[:space:]]*myorigin.*/myorigin = $POSTFIX_DOMAIN/' /etc/postfix/main.cf \
|| echo 'myorigin = $POSTFIX_DOMAIN' >> /etc/postfix/main.cf
grep -E '^relay'  /etc/postfix/main.cf && sed -i 's/^[#[:space:]]*relay.*/relay = [$POSTFIX_IP]:25/' /etc/postfix/main.cf \
|| echo 'relay = [$POSTFIX_IP]:25' >> /etc/postfix/main.cf
grep -E '^myhostname'  /etc/postfix/main.cf && sed -i "s/^[#[:space:]]*myhostname.*/myhostname = ${HOSTNAME}.$POSTFIX_DOMAIN/" /etc/postfix/main.cf \
|| echo "myhostname = ${HOSTNAME}.$POSTFIX_DOMAIN" >> /etc/postfix/main.cf