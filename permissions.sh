touch /etc/cron.allow /etc/at.allow
chmod 644 /etc/cron.allow /etc/at.allow
chown root:root /boot/grub/grub.cfg
chmod u-x,go-rwx /boot/grub/grub.cfg
chown root:root /etc/crontab
chmod og-rwx /etc/crontab
chown root:root /etc/crontab /etc/cron.*
chmod 700 /etc/cron.*
chown root:root /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config.d/*
chmod 600 /etc/ssh/sshd_config.d/*
chmod 600 /boot/grub/grub.cfg
chmod 640 /etc/cron.allow
chmod 640 /etc/shadow
chmod 640 /etc/shadow-
chmod 640 /etc/gshadow
chmod 640 /etc/gshadow-
chmod 700 /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules
find /var/log -type f -exec chmod 640 {} \;
find /var/log -type d -exec chmod 750 {} \;
grep -Pq -- '^daemon\b' /etc/group && l_group="daemon" || l_group="root"
[ ! -e "/etc/at.allow" ] && touch /etc/at.allow
chown root:"$l_group" /etc/at.allow
chmod u-x,g-wx,o-rwx /etc/at.allow
[ -e "/etc/at.deny" ] && chown root:"$l_group" /etc/at.deny
[ -e "/etc/at.deny" ] && chmod u-x,g-wx,o-rwx /etc/at.deny