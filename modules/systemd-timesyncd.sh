systemctl unmask systemd-timesyncd.service
systemctl --now enable systemd-timesyncd.service
grep -E '^[#]*NTP[[:space:]]*=' /etc/systemd/timesyncd.conf && sed -i 's/^[#]*NTP[[:space:]]*=/NTP=hora.roa.es/' /etc/systemd/timesyncd.conf \
|| echo 'NTP=hora.roa.es' >> /etc/systemd/timesyncd.conf

grep -E '^[#]*FallbackNTP[[:space:]]*=' /etc/systemd/timesyncd.conf \
&& sed -i 's/^[#]*FallbackNTP[[:space:]]*=/FallbackNTP=ntp.ubuntu.com/' /etc/systemd/timesyncd.conf \
|| echo 'NTP=ntp.ubuntu.com' >> /etc/systemd/timesyncd.conf