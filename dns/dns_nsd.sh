#!/bin/bash

#========================================================
# Filename: dns_nsd.sh
#
# Description: Script to install & configure DNS Server NSD
#
#========================================================

#========================================================
# install_configure_nsd
#
# install & configure DNS Server NSD
#
function install_configure_nsd 
{
        ${LOGGING} -i "Install authoritative DNS for : $domain_name"
        ${DNS}/nsd/installDNS_nsd.sh
        ${LOGGING} -i "Configure NSD"
		${DNS}/nsd/configDNS_nsd.sh $domain_name $ipv4 $revIpv4 $ipv6
        ${LOGGING} -i "Configure Forward Zone"
		${DNS}/nsd/configForwardZoneDNS_nsd.sh $domain_name $ipv4
        ${LOGGING} -i "Configure Backward Zone"
		${DNS}/nsd/configBackwardsZoneDNS_nsd.sh $domain_name $ipv4 $revIpv4
        ${LOGGING} -i "Final steps"
        ${DNS}/nsd/finalisationDNS_nsd.sh $domain_name $ipv4 $revIpv4
        ${LOGGING} -i "Test NSD"
        ${DNS}/nsd/testDNS_nsd.sh $domain_name $ipv4 $revIpv4

}

# --- MAIN ---
domain_name=$1
ipv4=$2
revIpv4=$3
ipv6=$4
install_configure_nsd