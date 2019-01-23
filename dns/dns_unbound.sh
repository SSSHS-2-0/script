#!/bin/bash

#========================================================
# Filename: dns_unbound.sh
#
# Description: Script to install & configure DNS Server Unbound
#
#========================================================

#========================================================
# install_configure_unbound
#
# install & configure DNS Server Unbound
#
function install_configure_unbound 
{
		if [ "$localhost_only" -eq 1 ] ; then
			${LOGGING} -i "Install DNS"
			${DNS}/unbound/installDNS_unbound.sh

			${LOGGING} -i "Configure DNS Hardening (Hide version, use root-hints file, use trust-anchored zones for DNSSEC requests)"
			${DNS}/unbound/configDNSHardening_unbound.sh		
		fi
       	${LOGGING} -i "Configure DNS Ports, IP's"
		${DNS}/unbound/configDNSListening_unbound.sh $localhost_only $local_ipv4 $local_ipv6

        ${LOGGING} -i "Configure DNS Access"
        ${DNS}/unbound/configDNSAccess_unbound.sh $localhost_only

		${LOGGING} -i "Configure this Client"
		${DNS}/unbound/finalisationDNS_unbound.sh $localhost_only $local_ipv4 $local_ipv6

}

# --- MAIN ---
localhost_only=$1
local_ipv4=$2
local_ipv6=$3
install_configure_unbound