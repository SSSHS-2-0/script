#!/bin/bash

#========================================================
# Filename: dnsRecords.sh
#
# Description: Add DNS records for mailserver
#========================================================

echo -en "\n"
${LOGGING} -i "Appending DNS records for the mailserver to zonefile"
echo -en "\n"
sed -i  '/^#.* MX.*10 /s/^#/ /' /etc/nsd/zones/$DOMAIN.forward 
sed -i  '/^#.* IN.*TXT /s/^#/ /' /etc/nsd/zones/$DOMAIN.forward 
echo "mail IN A $DOMAINIP" >>  /etc/nsd/zones/$DOMAIN.forward
echo "     IN TXT  \"v=spf1 mx a ~all\"" >>  /etc/nsd/zones/$DOMAIN.forward

echo -en "\n"
${LOGGING} -i "Reloading zone files.."
echo -en "\n"
nsd-control reload $DOMAIN > /dev/null 2>&1

