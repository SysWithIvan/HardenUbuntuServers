# HardenUbuntuServers
## Harden Ubuntu Linux servers to align with the CIS Benchmarks for Ubuntu.
## Starting up
```
mkdir /home/hardened
chmod 755 /home/hardened
cd /home/hardened
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
sudo mv /var/ossec/ruleset/sca/cis_ubuntu<version>.yml /var/ossec/ruleset/sca/cis_ubuntu<version>.yml.backup
sudo cp /home/hardened/HardenUbuntuServers/cis_ubuntu24-04.yml /var/ossec/ruleset/sca/
sudo chown root:wazuh /var/ossec/ruleset/sca/cis_ubuntu24-04.yml
sudo chmod 660 /var/ossec/ruleset/sca/cis_ubuntu24-04.yml
```

To reevaluate the new rule file, restart the agent:
```
sudo systemctl restart wazuh-agent
```

#### Once you have reload the rules, you have to go to the Wazuh Manager URL and go inside Agents Management Summary:

<img width="311" height="957" alt="image" src="https://github.com/user-attachments/assets/5a2ad643-6eb8-44b2-94b9-328a1a32d02b" />


#### Then, you choose your agent:

<img width="303" height="172" alt="image" src="https://github.com/user-attachments/assets/586abb97-262a-42ea-834c-d75d444038f6" />


#### Go into CIS benchmark:

<img width="948" height="412" alt="image" src="https://github.com/user-attachments/assets/d0f822b7-000a-4e99-8526-6b8e0d929393" />


#### And finally you can see the scan report:

<img width="1905" height="922" alt="image" src="https://github.com/user-attachments/assets/5209f630-621c-45d1-bccb-68a52e06cdbc" />


## Common issues
This script modify the ```/etc/fstab``` file, adding ro and noexec options to ```/home``` and ```/boot``` partitions. To solve this problem, edit the file, remove these options from /home and /boot and remount the partitions:
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


