#!/bin/bash

#========================================================
# Filename: finalisationDNS_nsd.sh
#
# Description: activate zones and NSD
#
#========================================================

#========================================================
# activate_zones
#
# activate zones and nsd service
#
function activate_zones {
	systemctl restart nsd   > /dev/null 2>&1
    # wait for nsd to become ready
    while true; do
        systemctl --quiet is-active nsd
        if [ $? -eq 0 ]; then
			sleep 4
            break
        else
            sleep 1
        fi
    done
    nsd-control addzone $domain_name $domain_name   > /dev/null 2>&1
	nsd-control addzone $revIpv4.in-addr.arpa $revIpv4.in-addr.arpa   > /dev/null 2>&1
	systemctl restart nsd   > /dev/null 2>&1
}

 # --- MAIN ---

domain_name=$1
ipv4=$2
revIpv4=$3

activate_zones
