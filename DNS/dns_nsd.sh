#!/bin/bash

#========================================================
# Filename: dns_nsd.sh
#
# Description: Script to install & configure DNS Server NSD
#
# Changed Version of SSSHS 1.0
#
#========================================================


#========================================================
# install_configure_nsd
#
# install & configure DNS Server NSD
#
function install_configure_nsd 
{
        
        if ! ./nsd/installDNS_nsd.sh; then
            exit 1
        fi
        
        ./nsd/configDNS_nsd.sh "$1" $ipv4 $revIpv4 $ipv6

        while read -r line; 
        do   
            configFZ=7
            configBZ=7
            fin=7
            test=7  
            domain_name=$line

            status $domain_name 20 $configFZ $configBZ $fin $test
            ./nsd/configForwardZoneDNS_nsd.sh $domain_name $ipv4
            configFZ=$?
            sleep 1

            status $domain_name 40 $configFZ $configBZ $fin $test
            ./nsd/configBackwardsZoneDNS_nsd.sh $domain_name $ipv4 $revIpv4
            configBZ=$?
            sleep 1

            status $domain_name 60 $configFZ $configBZ $fin $test
            ./nsd/finalisationDNS_nsd.sh $domain_name $ipv4 $revIpv4
            fin=$?
            sleep 1

            status $domain_name 80 $configFZ $configBZ $fin $test
            ./nsd/testDNS_nsd.sh $domain_name $ipv4 $revIpv4
            test=$?

            status $domain_name 100 $configFZ $configBZ $fin $test
            sleep 2

            result=$(( $configDNS+$configFZ+$configBZ+$fin+$test ))
            if [ $result -ne 0 ]; then
                dialog --backtitle "$BACKTITLE" --cr-wrap --msgbox "Failed to configure domain, this shouldn't happen.\nPlease create an issue on github." 0 0
                exit 1
            fi
            dialog --cr-wrap --msgbox "$(./user_info_domain.sh $domain_name $ipv4)" 1000 1000
        done < <(for item in ${domains[*]}; do echo "$item"; done)
        

}

function status {
    dialog --backtitle "$BACKTITLE" --mixedgauge "Install authoritative DNS for : $1" 0 0 $2 \
                    "Configure Forward Zone" $3 \
                    "Configure Backward Zone" $4 \
                    "Finalisation" $5 \
                    "Test NSD" $6
}
# --- MAIN ---
domains=($1)
ipv4=$2
revIpv4=$3
ipv6=$4
install_configure_nsd