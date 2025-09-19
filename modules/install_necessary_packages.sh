apt-get update -y || true
apt-get install -y libpam-pwquality
apt-get install aide aide-common -y
apt-get install -y audispd-plugins
apt-get install -y systemd-timesyncd
apt-get install -y systemd-journal-remote
apt-get install -y systemd-coredump
apt-get install -y apparmor apparmor-utils