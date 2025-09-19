grep -E '^myorigin'  /etc/postfix/main.cf && sed -i 's/^[#[:space:]]*myorigin.*/myorigin = $POSTFIX_DOMAIN/' /etc/postfix/main.cf \
|| echo 'myorigin = $POSTFIX_DOMAIN' >> /etc/postfix/main.cf
grep -E '^relay'  /etc/postfix/main.cf && sed -i 's/^[#[:space:]]*relay.*/relay = [$POSTFIX_IP]:25/' /etc/postfix/main.cf \
|| echo 'relay = [$POSTFIX_IP]:25' >> /etc/postfix/main.cf
grep -E '^myhostname'  /etc/postfix/main.cf && sed -i "s/^[#[:space:]]*myhostname.*/myhostname = ${HOSTNAME}.$POSTFIX_DOMAIN/" /etc/postfix/main.cf \
|| echo "myhostname = ${HOSTNAME}.$POSTFIX_DOMAIN" >> /etc/postfix/main.cf