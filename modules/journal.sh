systemctl unmask systemd-journal-upload.service
systemctl --now enable systemd-journal-upload.service

grep -E '^\s*\t*#*\s*\t*MaxFileSec\s*=' /etc/systemd/journald.conf && \
sed -i -E 's/^\s*\t*#*\s*\t*MaxFileSec\s*=.*/MaxFileSec=1month/' /etc/systemd/journald.conf \
|| echo 'MaxFileSec=1month' >> /etc/systemd/journald.conf

grep -E '^\s*\t*#*\s*\t*RuntimeKeepFree\s*=' /etc/systemd/journald.conf && \
sed -i -E 's/^\s*\t*#*\s*\t*RuntimeKeepFree\s*=.*/RuntimeKeepFree=50M/' /etc/systemd/journald.conf \
|| echo 'RuntimeKeepFree=50M' >> /etc/systemd/journald.conf

grep -E '^\s*\t*#*\s*\t*RuntimeMaxUse\s*=' /etc/systemd/journald.conf && \
sed -i -E 's/^\s*\t*#*\s*\t*RuntimeMaxUse\s*=.*/RuntimeMaxUse=200M/' /etc/systemd/journald.conf \
|| echo 'RuntimeMaxUse=200M' >> /etc/systemd/journald.conf

grep -E '^\s*\t*#*\s*\t*SystemKeepFree\s*=' /etc/systemd/journald.conf && \
sed -i -E 's/^\s*\t*#*\s*\t*SystemKeepFree\s*=.*/SystemKeepFree=500M/' /etc/systemd/journald.conf \
|| echo 'SystemKeepFree=500M' >> /etc/systemd/journald.conf

grep -E '^\s*\t*#*\s*\t*SystemMaxUse\s*=' /etc/systemd/journald.conf && \
sed -i -E 's/^\s*\t*#*\s*\t*SystemMaxUse\s*=.*/SystemMaxUse=1G/' /etc/systemd/journald.conf \
|| echo 'SystemMaxUse=1G' >> /etc/systemd/journald.conf

systemctl reload-or-restart systemd-journald