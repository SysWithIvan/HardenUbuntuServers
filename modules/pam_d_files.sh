grep -E '^\s*auth\s*required\s*pam_wheel.so\s*use_uid\s*group\s*=\s*.*'  /etc/pam.d/su && \
sed -i 's/^\s*auth\s*required\s*pam_wheel.so\s*use_uid\s*group\s*=\s*.*/auth required pam_wheel.so use_uid group=admins/'\
/etc/pam.d/su || echo 'auth required pam_wheel.so use_uid group=admins' >> /etc/pam.d/su

cat >/etc/pam.d/common-password <<'EOF'
# here are the per-package modules (the "Primary" block)
password        requisite                       pam_pwquality.so try_first_pass retry=3 minlen=8 minclass=3 difok=3
password        requisite                       pam_pwhistory.so remember=7 use_authtok
password        [success=3 default=ignore]      pam_krb5.so minimum_uid=5000
password        [success=2 default=ignore]      pam_unix.so obscure use_authtok try_first_pass yescrypt
password        [success=1 user_unknown=ignore default=die]     pam_ldap.so use_authtok try_first_pass
# here's the fallback if no module succeeds
password        requisite                       pam_deny.so
password        required                        pam_permit.so
EOF

cat >/etc/pam.d/common-auth <<'EOF'
# here are the per-package modules (the "Primary" block)
auth    [success=3 default=ignore]      pam_krb5.so minimum_uid=5000
auth    [success=2 default=ignore]      pam_unix.so try_first_pass
auth    [success=1 default=ignore]      pam_ldap.so use_first_pass
auth    requisite                       pam_deny.so
auth    required                        pam_permit.so
auth    optional                        pam_cap.so
EOF

find /etc/pam.d/ -type f -exec sed -i -E 's/(^|[[:space:]])nullok([[:space:]]|$)/\1\2/g' {} +