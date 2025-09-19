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

grep -E '^[^_]*action_mail_acct[^_]'  /etc/audit/auditd.conf && \
sed -i 's/^[#[:space:]]*action_mail_acct.*/action_mail_acct = $SUPPORT_MAIL/' /etc/audit/auditd.conf \
|| echo 'action_mail_acct = $SUPPORT_MAIL' >> /etc/audit/auditd.conf

find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) -exec chmod u-x,g-wx,o-rwx {} +
systemctl restart auditd || true