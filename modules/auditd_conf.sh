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

sed -ri 's|^\s*max_log_file\s*=.*|max_log_file = 10|' /etc/audit/auditd.conf

grep 'max_log_file_action'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*max_log_file_action .*/max_log_file_action = keep_logs/' /etc/audit/auditd.conf \
|| echo 'max_log_file_action = keep_logs' >> /etc/audit/auditd.conf

grep 'disk_full_action'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*disk_full_action .*/disk_full_action = single/' /etc/audit/auditd.conf \
|| echo 'disk_full_action = single' >> /etc/audit/auditd.conf

grep 'disk_error_action'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*disk_error_action .*/disk_error_action = syslog/' /etc/audit/auditd.conf \
|| echo 'disk_error_action = syslog' >> /etc/audit/auditd.conf

grep -E '^[^_]*admin_space_left_action[^_]'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*admin_space_left_action .*/admin_space_left_action = single/' /etc/audit/auditd.conf \
|| echo 'admin_space_left_action = single' >> /etc/audit/auditd.conf

grep -E '^[^_]*space_left_action[^_]'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*space_left_action .*/space_left_action = email/' /etc/audit/auditd.conf \
|| echo 'space_left_action = email' >> /etc/audit/auditd.conf

grep -E '^[^_]*admin_space_left[^_]'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*admin_space_left .*/admin_space_left = 1/' /etc/audit/auditd.conf \
|| echo 'admin_space_left = 1' >> /etc/audit/auditd.conf

grep -E '^[^_]*space_left[^_]'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*space_left .*/space_left = 500/' /etc/audit/auditd.conf \
|| echo 'space_left = 500' >> /etc/audit/auditd.conf

grep -E "^[^_]*action_mail_acct[^_]"  /etc/audit/auditd.conf && \
sed -i "s/^[#[:space:]]*action_mail_acct.*/action_mail_acct = ${SUPPORT_MAIL}/" /etc/audit/auditd.conf \
|| echo "action_mail_acct = ${SUPPORT_MAIL}" >> /etc/audit/auditd.conf

find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) -exec chmod u-x,g-wx,o-rwx {} +
systemctl restart auditd || true