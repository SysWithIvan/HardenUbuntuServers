CONF=/etc/systemd/system.conf
if grep -qE '^\s*CtrlAltDelBurstAction=' "$CONF"; then
  sed -ri 's|^\s*CtrlAltDelBurstAction\s*=.*|CtrlAltDelBurstAction=none|' "$CONF"
else
  echo 'CtrlAltDelBurstAction=none' >> "$CONF"
fi