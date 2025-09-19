cat >/etc/security/limits.conf <<'EOF'
* hard core 0
* hard maxlogins 2
* hard nproc 500
EOF
grep -E '^[#]*[[:space:]]*deny[[:space:]]*=' /etc/security/faillock.conf && \
sed -i 's/^[#]*[[:space:]]*deny[[:space:]]*=.*/deny=5/' /etc/security/faillock.conf \
|| echo 'deny=5' >> /etc/security/faillock.conf

grep -E '^[#]*[[:space:]]*even_deny_root[[:space:]]*' /etc/security/faillock.conf && \
sed -i 's/^[#]*[[:space:]]*even_deny_root[[:space:]]*/even_deny_root/' /etc/security/faillock.conf \
|| echo 'even_deny_root' >> /etc/security/faillock.conf

grep -E '^[#]*[[:space:]]*root_unlock_time[[:space:]]*=' /etc/security/faillock.conf && \
sed -i 's/^[#]*[[:space:]]*root_unlock_time[[:space:]]*=.*/root_unlock_time=60/' /etc/security/faillock.conf \
|| echo 'root_unlock_time=60' >> /etc/security/faillock.conf

grep -E '^[#]*[[:space:]]*unlock_time[[:space:]]*=' /etc/security/faillock.conf && \
sed -i 's/^[#]*[[:space:]]*unlock_time[[:space:]]*=.*/unlock_time=900/' /etc/security/faillock.conf \
|| echo 'unlock_time=900' >> /etc/security/faillock.conf

grep -E '^\s*[#]*\s*maxrepeat\s*=\s*.*'  /etc/security/pwquality.conf && \
sed -i 's/^\s*[#]*\s*maxrepeat\s*=\s*.*/maxrepeat=3/' /etc/security/pwquality.conf \
|| echo 'maxrepeat=3' >> /etc/security/pwquality.conf

grep -E '^\s*[#]*\s*minlen\s*=\s*.*'  /etc/security/pwquality.conf && \
sed -i 's/^\s*[#]*\s*minlen\s*=\s*.*/minlen=8/' /etc/security/pwquality.conf \
|| echo 'minlen=8' >> /etc/security/pwquality.conf

grep -E '^\s*[#]*\s*difok\s*=\s*.*'  /etc/security/pwquality.conf && \
sed -i 's/^\s*[#]*\s*difok\s*=\s*.*/difok=2/' /etc/security/pwquality.conf \
|| echo 'difok=2' >> /etc/security/pwquality.conf

grep -E '^\s*[#]*\s*maxsequence\s*=\s*.*'  /etc/security/pwquality.conf && \
sed -i 's/^\s*[#]*\s*maxsequence\s*=\s*.*/maxsequence=3/' /etc/security/pwquality.conf \
|| echo 'maxsequence=3' >> /etc/security/pwquality.conf

grep -E '^\s*[#]*\s*minclass\s*=\s*.*'  /etc/security/pwquality.conf && \
sed -i 's/^\s*[#]*\s*minclass\s*=\s*.*/minclass=4/' /etc/security/pwquality.conf \
|| echo 'minclass=4' >> /etc/security/pwquality.conf