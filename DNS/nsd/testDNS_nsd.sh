#!/bin/bash

#========================================================
# Filename: testDNS_nsd.sh
#
# Description: test the forward and backward zone
#
# Changed Version of SSSHS 1.0
#
#========================================================

#========================================================
# testDNS
#
# test the domain entries
#
function testDNS {
	dialog --backtitle "$BACKTITLE" --infobox "Test forward zone" 0 0
	dig +noadditional +noquestion +nocomments +nocmd +nostats ${domain_name}. @${ipv4} > /dev/null 2>&1
	fz=$?
	dialog --backtitle "$BACKTITLE" --infobox "Test backward zone" 0 0
	dig PTR +noadditional +noquestion +nocomments +nocmd +nostats ${revIpv4}.in-addr.arpa. @${ipv4} > /dev/null 2>&1
	bz=$?
	result=$(( $fz+$bz ))
	if [ $result -ne 0 ]; then
		exit 1
	fi

}

# --- MAIN ---

domain_name=$1
ipv4=$2
revIpv4=$3

testDNS
