#!/bin/bash

#========================================================
# Filename: testDNS.sh
#
# Description: test the DNS with a ipv4 and a ipv6 address
#
#========================================================


#========================================================
# testDNS
#
# test the DNS with a ipv4 and a ipv6 address
#
function testDNS {
 ${LOGGING} -i "Test ipv4 address"
dig +noall +answer -4 www.google.com
 ${LOGGING} -i "Test ipv6 address"
 dig AAAA +noall +answer ipv6.google.com
}

# --- MAIN ---

testDNS
