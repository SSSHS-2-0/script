#!/bin/bash

#========================================================
# Filename: restart.sh
#
# Description: Restart all components for SSH at the end of configuration
#========================================================

echo -en "\n"
${LOGGING} -i "Restarting all components for SSH"
echo -en "\n"

#sed -i '/-A ufw-before-output -o lo -j ACCEPT/a \\n# hand off control for sshd to sshguard\n-N sshguard\n-A ufw-before-input -p tcp --dport 22 -j sshguard' /etc/ufw/before.rules

#systemctl stop  ufw && sleep 2
#systemctl start ufw
#systemctl start ufw
#systemctl restart sshguard
systemctl restart sshd
