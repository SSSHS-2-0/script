 #!/bin/bash

#========================================================
# Filename: configDNS_nsd.sh
#
# Description: Configure the NSD Server
#
# Source: SSSHS 1.0
#
#========================================================

#========================================================
# create_config
#
# creates config for nsd
#
function create_config {
 cat << EOF > /etc/nsd/nsd.conf
server:
  # uncomment to specify specific interfaces to bind (default all).
    ip-address: ${ipv4}
    ${ipv6entry}

  # port to answer queries on. default is 53.
    port: 53

  # Number of NSD servers to fork.
    server-count: 1

  # listen only on IPv4 connections
    ip4-only: ${ipv4only}

  # don't answer VERSION.BIND and VERSION.SERVER CHAOS class queries
    hide-version: yes

  # identify the server (CH TXT ID.SERVER entry).
    identity: ""

    logfile: "/var/log/nsd.log"

# The directory for zonefile: files.
    zonesdir: "/etc/nsd/zones"
    pidfile: "/etc/nsd/nsd.pid"
    username: nsd

EOF

while read -r line; 
do   
  domain_name=$line
  cat << EOF >> /etc/nsd/nsd.conf
pattern:
    name: ${domain_name}
    zonefile: ${domain_name}.forward
pattern:
    name: ${revIpv4}.in-addr.arpa
    zonefile: ${domain_name}.backward
EOF
done < <(for item in ${domains[*]}; do echo "$item"; done)

}
 # --- MAIN ---
 domains=($1)
 revIpv4=$3
 ipv4=$2
 ipv6=$4
if [ -z "$ipv6" ] ; then
 	ipv6entry="#ip-address: ${ipv6}"
 	ipv4only="yes"
else
	ipv6entry="ip-address: ${ipv6}"
	ipv4only="no"
fi
 create_config
