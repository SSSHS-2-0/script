#!/bin/bash

#========================================================
# Filename: configDNSAccess.sh
#
# Description: Configure the Access to the DNS Server
#
# Source: SSSHS 1.0
#
#========================================================


#========================================================
# init
#
# prepare access file, and used for localhost only configuration
#
function init {
cat << EOF > /etc/unbound/unbound.conf.d/access.conf
server:

EOF
}

#========================================================
# local_clients
#
# Add default local IP addresses
#
function local_clients {
cat << EOF >> /etc/unbound/unbound.conf.d/access.conf
    access-control: 10.0.0.0/8 allow
    access-control: 127.0.0.0/8 allow
    access-control: 192.168.0.0/16 allow
    access-control: fd00::/8 allow # equivalent to IPv4 private ranges
EOF
}

# --- MAIN ---

init

# Checks if user only use localhost configuration
if [ $1 -ne 1 ] ; then  
		local_clients
fi
