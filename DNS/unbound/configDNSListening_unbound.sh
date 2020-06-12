#!/bin/bash

#========================================================
# Filename: configDNSListening.sh
#
# Description: Configure the listening part of the DNS Server
#
# Changed Version of SSSHS 1.0
#
#========================================================

#========================================================
# only_localhost
#
# creates config for localhost only
#

function only_localhost {
cat << EOF > /etc/unbound/unbound.conf.d/listening.conf
server:
   #set dns listening for ipv4
   interface: 127.0.0.1 
   
   #set dns listening for ipv6
   interface: ::1
EOF
}

#========================================================
# only_localhost
#
# creates config with ipv4 and ipv6 addresses
#

function not_localhost {
cat << EOF > /etc/unbound/unbound.conf.d/listening.conf
server:
   #set dns listening for ipv4
   interface: 127.0.0.1 
   interface: ${ipv4}
   
   #set dns listening for ipv6
   interface: ::1
   ${ipv6entry}
EOF
}

#========================================================
# enablePorts
#
# enables Ports and ipv4 and ipv6
#

function enablePorts { 
cat << EOF >> /etc/unbound/unbound.conf.d/listening.conf

   # port to answer queries from
    port: 53

   # Enable IPv4, "yes" or "no".
    do-ip4: yes

   # Enable IPv6, "yes" or "no".
    do-ip6: ${doIpv6}

   # Enable UDP, "yes" or "no".
    do-udp: yes
   
   # Enable TCP, "yes" or "no".
    do-tcp: yes
EOF
}

# --- MAIN ---

if [ "$1" -eq 1 ] ; then
 dialog --backtitle "$BACKTITLE" --msgbox "DNS will listen with localhost on port 53" 0 0
 doIpv6="yes"
 only_localhost
else
 ipv4=$2
 ipv6=$3
if [ -z "$ipv6" ] ; then
        ipv6entry="#interface: ${ipv6}"
	doIpv6="no"
   dialog --backtitle "$BACKTITLE" --msgbox "DNS will listen with $ipv4 (and $ipv6 ) on port 53" 0 0
else
        ipv6entry="interface: ${ipv6}"
	doIpv6="yes"
   dialog --backtitle "$BACKTITLE" --msgbox "DNS will listen with $ipv4 (and $ipv6 ) on port 53" 0 0
fi

 not_localhost
fi

enablePorts
