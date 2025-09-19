sed -ri 's|^(\S+\s+/boot\s+)\S+.*|\1ext4 nodev,nosuid,noexec,ro 0 2|' /etc/fstab
sed -ri 's|^(\S+\s+/home\s+)\S+.*|\1ext4 defaults,nodev,nosuid,noexec,usrquota 0 0|' /etc/fstab
grep -E ' /tmp .*noexec'  /etc/fstab || sed -i -E 's/^(.+[[:space:]]+\/tmp[[:space:]]+.+[[:space:]]+.+)([[:space:]]+.+[[:space:]]+.+)/\1,noexec\2/' /etc/fstab
grep -E ' /var/tmp .*noexec'  /etc/fstab || sed -i -E 's/^(.+[[:space:]]+\/var\/tmp[[:space:]]+.+[[:space:]]+.+)([[:space:]]+.+[[:space:]]+.+)/\1,noexec\2/' /etc/fstab