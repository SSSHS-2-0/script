#!/bin/bash

#========================================================
# Filename: install.sh
#
# Description: 
#   Install script for Snort.
#
#========================================================

if $UTILS/select_interface.sh "Select interface for Snort"; then
        interface=$(cat selected_interface)
        rm selected_interface
else
       dialog --msgbox "Interface selection failed. Exiting..." 0 0
       exit 0
fi

dialog --backtitle "$BACKTITLE" --colors --cr-wrap --msgbox "Ready to install snort, you selected \n\n\Zb\Z1$interface\Zn\n\nenter this in the install progress.\nMaybe snort tells you the interface is wrong, ignore that.\nUse \n\n\Zb\Z1$($UTILS/getIpv4.sh)/32\Zn\n\nas Network range.\n write this down because you will need it shortly" 0 0

# install snort without the gui

apt install -y libpcap-dev bison flex 
apt install -y snort
dialog --infobox "starting snort NIDS on interface ${interface}..." 0 0

# start snort NIDS
snort -i $interface -l /var/log/snort -A fast -c /etc/snort/snort.conf -D

#inform user and make installed file
dialog --infobox  "started snort NIDS on interface ${interface}" 0 0
sleep 2
$LOGGING -i "Installed module Snort"
touch installed