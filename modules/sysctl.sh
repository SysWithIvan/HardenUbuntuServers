printf "%s\n" "kernel.randomize_va_space = 2" >> /etc/sysctl.d/60-kernel_sysctl.conf
tee /etc/sysctl.d/60-icmp-redirects.conf >/dev/null <<'EOF'
# Deshabilitar ICMP redirects (IPv4/IPv6)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
EOF
cat > /etc/sysctl.d/60-netipv6_sysctl.conf <<'EOF'
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
EOF
printf '%s\n' "net.ipv4.conf.all.log_martians = 1" "net.ipv4.conf.default.log_martians = 1"\
              "net.ipv4.route.flush=1" "net.ipv4.conf.default.send_redirects=0"\
              "net.ipv4.conf.all.send_redirects=0" "net.ipv4.conf.all.secure_redirects=0"\
              "net.ipv4.conf.all.secure_redirects=0" "net.ipv4.conf.default.secure_redirects=0"\
              "net.ipv4.conf.all.rp_filter=1" "net.ipv4.conf.default.rp_filter=1"\
              "net.ipv4.conf.all.accept_source_route=0" "net.ipv4.conf.default.accept_source_route=0"\
              > /etc/sysctl.d/60-netipv4_sysctl.conf
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv4.route.flush=1
sysctl -w net.ipv4.conf.default.send_redirects=0
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv4.conf.default.accept_source_route=0
sysctl -w net.ipv6.conf.all.accept_source_route=0
sysctl -w net.ipv6.conf.default.accept_source_route=0
printf "%s\n" "fs.suid_dumpable = 0" > /etc/sysctl.d/60-fs_sysctl.conf

sysctl -w fs.suid_dumpable=0
sysctl -w net.ipv6.conf.all.accept_ra=0
sysctl -w net.ipv6.conf.default.accept_ra=0
sysctl -w net.ipv6.route.flush=1
sysctl --system