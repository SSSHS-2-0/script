#! /bin/bash
#========================================================
# Filename: user_ifo_domain.sh
#
# Description: 
#   Displays some very important information for the user
# 
#========================================================

domain_name=$1
ipv4=$2

echo "You have a full functional authoritative Name Server BUT your domain hoster does not know it!"
echo "VERY IMPORTANT GO to your domain hoster, change the name server for your domain to :"
echo "        ns1.$domain_name with IP: $ipv4"
echo "        ns2.$domain_name with IP: $ipv4"
echo "VERY IMPORTANT DO the same for the Glue Records, with the same name server and IP's"
echo ""
echo "It may take some time to change it"