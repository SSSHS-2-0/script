#!/bin/bash

#========================================================
# Filename: finalisationDNS.sh
#
# Description: set resolv.conf and restart service
#
# Changed Version of SSSHS 1.0
#
#========================================================

#========================================================
# only_localhost
#
# configure resolv.conf for localhost use only
#
function only_localhost {
        echo "nameserver 127.0.0.1" >> /etc/resolv.conf
        echo "nameserver ::1" >> /etc/resolv.conf
}

#========================================================
# not_only_localhost
#
# configure resolv.conf with specific ipv4 and ipv6 address
#
function not_only_localhost {
        echo "nameserver 127.0.0.1" >> /etc/resolv.conf
        echo "nameserver ::1" >> /etc/resolv.conf
        echo "nameserver $ipv4" >> /etc/resolv.conf
	if [ ! -z "$ipv6" ] ; then 
        echo "nameserver $ipv6" >> /etc/resolv.conf      
	fi
}

#========================================================
# disable_systemd-resolver
#
# disable and stop systemd-resolver
#

function disable_systemd-resolver {
	systemctl disable systemd-resolved.service   > /dev/null 2>&1
	systemctl stop systemd-resolved   > /dev/null 2>&1
}
# --- MAIN ---
sed -i 's/^/#/g' /etc/resolv.conf	
if [ "$1" -eq 1 ] ; then
 
 only_localhost
else
 ipv4=$2
 ipv6=$3
 if [ -z "$ipv6" ] ; then
        dialog --backtitle "$BACKTITLE" --msgbox "Server will use $ipv4 as DNS" 0 0
 	${LOGGING} -i ""
else
        dialog --backtitle "$BACKTITLE" --msgbox "Server will use $ipv4 (and $ipv6 ) as DNS" 0 0
fi

 not_only_localhost
fi

# --- restart dns for usage --- 
disable_systemd-resolver
systemctl restart unbound
