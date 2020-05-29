#!/bin/bash

#========================================================
# Filename: testDNS.sh
#
# Description: test the DNS with a ipv4 and a ipv6 address
#
# Changed Version of SSSHS 1.0
#
#========================================================


#========================================================
# testDNS
#
# test the DNS with a ipv4 and a ipv6 address
#
function testDNS {
 
 dialog --backtitle "$BACKTITLE" --infobox "Test ipv4 address" 0 0
 dig +noall +answer -4 www.google.com > /dev/null 2>&1
 ipv4=$?

 dialog --backtitle "$BACKTITLE" --infobox "Test ipv6 address" 0 0
 dig AAAA +noall +answer ipv6.google.com > /dev/null 2>&1
 ipv6=$?

 result=$(( $ipv4+$ipv6 ))
 if [ $result -ne 0 ]; then
     exit 1
 fi
}

# --- MAIN ---

testDNS
