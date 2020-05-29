#!/bin/bash

#========================================================
# Filename: dns_unbound.sh
#
# Description: Script to install & configure DNS Server Unbound
#
# Changed Version of SSSHS 1.0
#
#========================================================

#========================================================
# install_configure_unbound
#
# install & configure DNS Server Unbound
#

#This function sadly needs to be in every script
function check {
        if ! eval "./$1"; then
            exit 1
        fi
}

function install_configure_unbound 
{
		if [ "$localhost_only" -eq 1 ] ; then
			dialog --backtitle "$BACKTITLE" --infobox "Install DNS" 0 0
			check "unbound/installDNS_unbound.sh"

			dialog --backtitle "$BACKTITLE" --infobox "Configure DNS Hardening (Hide version, use root-hints file, use trust-anchored zones for DNSSEC requests)" 0 0
			check "unbound/configDNSHardening_unbound.sh"		
		fi
		
		dialog --backtitle "$BACKTITLE" --infobox "Configure DNS Ports, IP's" 0 0
		check "unbound/configDNSListening_unbound.sh $localhost_only $local_ipv4 $local_ipv6"

		dialog --backtitle "$BACKTITLE" --infobox "Configure DNS Access" 0 0
        check "unbound/configDNSAccess_unbound.sh $localhost_only"

		dialog --backtitle "$BACKTITLE" --infobox "Configure this Client" 0 0
		check "unbound/finalisationDNS_unbound.sh $localhost_only $local_ipv4 $local_ipv6"

}

# --- MAIN ---
localhost_only=$1
local_ipv4=$2
local_ipv6=$3
install_configure_unbound