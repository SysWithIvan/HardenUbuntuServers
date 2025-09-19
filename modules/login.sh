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