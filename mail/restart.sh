#!/bin/bash

#========================================================
# Filename: restart.sh
#
# Description: Restart all components of the mailserver at the end of configuration
#========================================================

echo -en "\n"
${LOGGING} -i "Restarting all components of the mailserver"
echo -en "\n"

nsd-control reload $DOMAIN > /dev/null 2>&1
systemctl restart nsd
systemctl restart opendkim
systemctl restart opendmarc
systemctl restart postfix
systemctl restart dovecot
