#!/bin/bash

#========================================================
# Filename: chooseIP.sh
#
# Description: let the user choose an IP
#              returns Ipv4 or Ipv6 Address
#
#========================================================

#========================================================
# chooseIP
#
# let the user choose an IP of all ip's available 
#
function chooseIP {
        PS3='Please choose IP: '
		if [ -z "$ipUsed" ]; then 
			allIpv=( `${DNS}/../utils/getAllIpv${version}.sh | tr '\n' ' '` )
		else
			allIpv=( `${DNS}/../utils/getAllIpv${version}.sh | grep -v ${ipUsed} | tr '\n' ' '` )
		fi
		select ip_choosen in "${allIpv[@]}"; do
    	echo "$ip_choosen"
		break
		done
		}

# --- MAIN ---

version=$1
ipUsed=$2

chooseIP
