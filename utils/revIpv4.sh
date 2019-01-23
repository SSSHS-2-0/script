#!/bin/bash

#========================================================
# Filename: revIpv4.sh
#
# Description: returns reverse Ipv4 Address
#
#========================================================

#========================================================
# getRevIpv4
#
# Returns the reverse ipv4 address
#
function getRevIpv4 {
        echo $1 | awk -F. '{print $4"."$3"." $2"."$1}'
}

# --- MAIN ---

getRevIpv4 $1
