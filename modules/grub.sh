cat >/etc/default/grub <<EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR="$(lsb_release -i -s 2>/dev/null || echo Debian)"
GRUB_CMDLINE_LINUX_DEFAULT="apparmor=1 security=apparmor audit=1 audit_backlog_limit=8192"
GRUB_CMDLINE_LINUX="audit=1"
GRUB_DISABLE_RECOVERY="true"
EOF

cat >/etc/default/grub.d/99-hardening.cfg <<'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR="$(lsb_release -i -s 2>/dev/null || echo Debian)"
GRUB_CMDLINE_LINUX_DEFAULT="apparmor=1 security=apparmor audit=1 audit_backlog_limit=8192"
GRUB_CMDLINE_LINUX="audit=1"
GRUB_DISABLE_RECOVERY="true"
EOF

update-grub