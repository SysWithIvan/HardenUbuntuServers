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