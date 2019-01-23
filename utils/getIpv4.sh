#!/bin/bash

#========================================================
# Filename: getIpv4.sh
#
# Description: returns Ipv4 Address
#
#========================================================

#========================================================
# getIpv4
#
# Returns the first ipv4 address which is not the localhost address (127.0.0.1)
#
function getIpv4 {
        ip -o -4 addr list  | grep -v 127.0.0.1 | head -n 1 | awk '{print $4}' | cut -d/ -f1
}

# --- MAIN ---

getIpv4
