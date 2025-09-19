# HardenUbuntuServers
## Harden Ubuntu Linux servers to align with the CIS Benchmarks for Ubuntu.
## Starting up
```
git clone https://github.com/SysWithIvan/HardenUbuntuServers.git
cd HardenUbuntuServers 
```
At the top of ```harden.sh``` you’ll find environment variables you must adapt to your environment (banners, allowed networks, mail, and Postfix settings).

```
vi harden.sh

# Edit with correct data
AUTHORIZED_TEXT="

Put something useful to warn about the consequences of a bad use of the systems

"
HOSTS_ALLOW_TEXT="
sshd: --> put networks which from can access using ssh login 
slapd: --> put networks which from can validate across LDAP/Kerberos
"
SUPPORT_MAIL="
Put the mail which will receive the alerts, such as the space left on device alert.
"
POSTFIX_DOMAIN="
mydomain.net
"
POSTFIX_IP="
my_relay_ip
"
```
Save your changes and run:
```
sudo chmod -R +x .
sudo ./harden.sh
```
## Verifying the hardening
### WAZUH (recommended)
Wazuh is an open-source SIEM/XDR. Among other capabilities (vulnerability detection, malware detection, FIM…), it runs Security Configuration Assessment (SCA) policies mapped to CIS Benchmarks.

Here you can access to the [Wazuh installation guide](https://documentation.wazuh.com/current/installation-guide/index.html)

Instead of replacing the built-in policy, copy this repo’s SCA file to the wazuh SCA dir:
```
sudo mv /var/ossec/ruleset/sca/cis_ubuntu24-04.yml /var/ossec/ruleset/sca/cis_ubuntu24-04.yml.backup
sudo cp HardenUbuntuServers/cis_ubuntu24-04.yml /var/ossec/ruleset/sca/
sudo chown root:wazuh /var/ossec/ruleset/sca/cis_ubuntu24-04.yml
sudo chmod 660 /var/ossec/ruleset/sca/cis_ubuntu24-04.yml
```

To reevaluate the new rule file, restart the agent:
```
sudo systemctl restart wazuh-agent
```

#### Once you have reload the rules, you have to go to the Wazuh Manager URL and go inside Agents Management Summary:

![Not image available](https://private-user-images.githubusercontent.com/51971959/491494810-96c95a0c-535e-43a2-bcd2-940187d36c30.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTgyNzQwOTMsIm5iZiI6MTc1ODI3Mzc5MywicGF0aCI6Ii81MTk3MTk1OS80OTE0OTQ4MTAtOTZjOTVhMGMtNTM1ZS00M2EyLWJjZDItOTQwMTg3ZDM2YzMwLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA5MTklMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwOTE5VDA5MjMxM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWZkYzBlMzNlODBmOThhMzE2NGY5ZjBmOTUxZjUyNDZlNGY0YjNmZDQ1OTQ4MTRhNTM1ZDQ0MTJiYWRmNzNmNWYmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.NeJE4w3rYDqEP63siVhj6KqmvtUmYPELdCcOieizakw)

#### Then, you choose your agent:

![Not image available](https://private-user-images.githubusercontent.com/51971959/491495482-052d0a7c-4f0a-4a5d-a14b-881ff64529b9.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTgyNzQwOTMsIm5iZiI6MTc1ODI3Mzc5MywicGF0aCI6Ii81MTk3MTk1OS80OTE0OTU0ODItMDUyZDBhN2MtNGYwYS00YTVkLWExNGItODgxZmY2NDUyOWI5LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA5MTklMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwOTE5VDA5MjMxM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTljMTkwMDFjNjJlNWU0YzRjMDhlNDJiNmFjZTk0ZmY4MjllYWNkNjZiNWUyMmNkMGY1OTFmOGMyOGE4NTQ0MTgmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.6QRjgrWkMBWLHnSucFKvNZcy9vU-r3xrgR0Cjjff8wA)

#### Go into CIS benchmark:
![Not image available](https://private-user-images.githubusercontent.com/51971959/491495779-63f2ddfb-9ce3-4ba3-819f-3839bf6681cd.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTgyNzQwOTMsIm5iZiI6MTc1ODI3Mzc5MywicGF0aCI6Ii81MTk3MTk1OS80OTE0OTU3NzktNjNmMmRkZmItOWNlMy00YmEzLTgxOWYtMzgzOWJmNjY4MWNkLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA5MTklMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwOTE5VDA5MjMxM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTcxNWFmZjk1ZDRmMmI5MDYzNDJkYTIyNzE1MzMyODIzODJmMmNhYjRjODgwZDU2OTUyOWVkYjhkYjVlMzMyZjgmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.sJwWLlpH2HVp-u0qXhWorXcx1DiD7ifkkQsyy6aWbb8)

#### And finally you can see the scan report:
![alt text](https://private-user-images.githubusercontent.com/51971959/491496212-0c7ddc29-00be-4a3f-95d0-9a90ff5eb1d7.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTgyNzQwOTMsIm5iZiI6MTc1ODI3Mzc5MywicGF0aCI6Ii81MTk3MTk1OS80OTE0OTYyMTItMGM3ZGRjMjktMDBiZS00YTNmLTk1ZDAtOWE5MGZmNWViMWQ3LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA5MTklMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwOTE5VDA5MjMxM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTBhMThmZWU5MjQ4MDJiOTk4ZDVhMzQ4N2Y0MjMyY2YwMjVkMTUxYjc3NTllNGJlZWYzZmY3NTA1YTA0YzJkNDYmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0._zntxxz02yB_EjLXtMFON2Bl75fg0x8dDCw8KnC9kMo)

## Common issues
This script modify the ```/etc/fstab``` file, adding ro and noexec options to ```/home``` and ```/boot``` partitions. To solve this problem, edit the file, remove these options form /home and /boot and remount the partitions:
```
mount -o remount /home
mount -o remount /boot
```
## Considerations
This project targets Ubuntu 24.04 and a specific environment. The provided SCA file intentionally differs from the official Wazuh policy. Some CIS controls (for example, partitioning requirements) are not implemented by the script and will appear as failed.

## Contact

If you want to help to improve this project, you have any doubt or suggestion, please contact with me:

Mail: ivantexenery@gmail.com

LinkedIn: [SysWithIvan](www.linkedin.com/in/iván-texenery-díaz-garcía-060621182)