#!/bin/bash

#========================================================
# Filename: getIpv6.sh
#
# Description: returns Ipv6 Address
#
# Source: from SSSHS 1.0
#
#========================================================

#========================================================
# getIpv6
#
# Returns the first ipv6 address which is not the localhost (::1) address
#
function getIpv6 {
        ip=`ip -o -6 addr list  | grep -wv ::1 | awk '{print $4}' | cut -d/ -f1`
        ips=( `echo $ip | tr '\n' ' '` )
        for ipsv6 in "${ips[@]}"
        do
          sipcalc $ipsv6 | grep "Address type" | grep -q "Link-Local Unicast Addresses"
          if [ $? ] ; then
                echo -n ""
           else
                sipcalc "$ipsv6" | grep "Expanded Address" | awk '{print $NF}'
           fi
        done
}


# --- MAIN ---

getIpv6
