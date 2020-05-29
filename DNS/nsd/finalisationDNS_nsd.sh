#!/bin/bash

#========================================================
# Filename: finalisationDNS_nsd.sh
#
# Description: activate zones and NSD
#
# Source: SSSHS 1.0
#
#========================================================

#========================================================
# activate_zones
#
# activate zones and nsd service
#
function activate_zones {
    chmod 666 /var/lib/nsd/zone.list > /dev/null 2>&1
    service unbound stop
    sleep 5
	service nsd stop 
    sleep 5
    nsd-control addzone $domain_name $domain_name   > /dev/null 2>&1
	nsd-control addzone $revIpv4.in-addr.arpa $revIpv4.in-addr.arpa   > /dev/null 2>&1
	sleep 5
    service nsd restart
    sleep 5
    service unbound restart
    sleep 5
}

 # --- MAIN ---

domain_name=$1
ipv4=$2
revIpv4=$3

activate_zones
