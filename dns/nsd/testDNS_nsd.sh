#!/bin/bash

#========================================================
# Filename: testDNS_nsd.sh
#
# Description: test the forward and backward zone
#
#========================================================

#========================================================
# testDNS
#
# test the domain entries
#
function testDNS {
	echo "Test forward zone"
	dig +noadditional +noquestion +nocomments +nocmd +nostats ${domain_name}. @${ipv4}
	echo "Test backward zone"
	dig PTR +noadditional +noquestion +nocomments +nocmd +nostats ${revIpv4}.in-addr.arpa. @${ipv4}
}

# --- MAIN ---

domain_name=$1
ipv4=$2
revIpv4=$3

testDNS
