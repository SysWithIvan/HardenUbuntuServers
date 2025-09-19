useradd -D -f 45
awk -F: 'NR==FNR { if ($3>=1000 && $1!="nobody") u[$1]=1; next }
          ($1 in u) && ($2 ~ /^\$/) && ($7 > 45 || $7 < 0) { print $1 ":" $7 }' \
    /etc/passwd /etc/shadow

awk -F: 'NR==FNR { if ($3>=1000 && $1!="nobody") u[$1]=1; next }
          ($1 in u) && ($2 ~ /^\$/) && ($7 > 45 || $7 < 0) { print $1 }' \
    /etc/passwd /etc/shadow \
 | xargs -r -n1 chage --inactive 45

awk -F: 'NR==FNR { if($3>=1000 && $1!="nobody") u[$1]=1; next }
          ($1 in u) && ($2 ~ /^\$/) && ($4 < 1) { print $1 }' \
    /etc/passwd /etc/shadow | xargs -r -n1 chage --mindays 1

awk -F: '($2 ~ /^\$/) && ($5 > 365 || $5 < 1) {print $1}' /etc/shadow \
 | xargs -r -n1 chage --maxdays 365

awk -F: '($2~/^\$/) && ($4 < 1) {print $1 ":" $4}' /etc/shadow || true