tee /etc/logrotate.d/wtmp >/dev/null <<'EOF'
/var/log/wtmp {
  monthly
  missingok
  create 0640 root utmp
  rotate 1
}
EOF

tee /etc/logrotate.d/btmp >/dev/null <<'EOF'
/var/log/btmp {
  monthly
  missingok
  create 0600 root utmp
  rotate 1
}
EOF
tee /etc/logrotate.d/apt >/dev/null <<'EOF'
/var/log/apt/term.log {
  rotate 52
  weekly
  compress
  missingok
  notifempty
  create 0640 root adm
}

/var/log/apt/history.log {
  rotate 52
  weekly
  compress
  missingok
  notifempty
  create 0640 root adm
}
EOF
tee /etc/tmpfiles.d/zz-log-perms.conf >/dev/null <<'EOF'
z /var/log/wtmp    0640 root utmp - -
z /var/log/lastlog 0640 root utmp - -
z /var/log/btmp    0600 root utmp - -
EOF
cat >/etc/tmpfiles.d/99-apt-logs.conf <<'EOF'
f /var/log/apt/history.log 0640 root adm -
f /var/log/apt/eipp.log.xz 0640 root adm -
EOF
sed -i 's/create 644 root root/create 640 root adm/' /etc/logrotate.d/alternatives
sed -i 's/create 644 root root/create 640 root adm/' /etc/logrotate.d/dpkg
sed -i 's/create 0644 root root/create 0640 root adm/' /etc/logrotate.d/ubuntu-pro-client

sed -i -E '/^[[:space:]]*\/var\/log\/wtmp[[:space:]]*\{/,/^[[:space:]]*\}/d' /etc/logrotate.conf
sed -i -E '/^[[:space:]]*\/var\/log\/btmp[[:space:]]*\{/,/^[[:space:]]*\}/d' /etc/logrotate.conf
systemd-tmpfiles --create
logrotate -f /etc/logrotate.conf