 #!/bin/bash

#========================================================
# Filename: configBackwardsZoneDNS_nsd.sh
#
# Description: Configure the the Forward Zone
#
# Source: SSSHS 1.0
#
#========================================================

#========================================================
# create_backward_zone
#
# creates backward zone
#

function create_backward_zone {
 cat << EOF >> /etc/nsd/zones/${domain_name}.backward

\$ORIGIN ${revIpv4}.in-addr.arpa.
\$TTL 1800

@ IN SOA ns1.${domain_name}. ns2.${domain_name}. (
           ${serial}   ; serial number
           28800       ; Refresh
           7200        ; Retry
           1209600     ; Expire
           86400       ; Min TTL
           )

           NS      ns1.${domain_name}.
           NS      ns2.${domain_name}.
; PTR
                       IN      PTR     ${domain_name}.
                       IN      PTR     mail.${domain_name}.
EOF
}

# --- MAIN ---

domain_name=$1
ipv4=$2
revIpv4=$3
serial=`date +%Y%m%d%H`
create_backward_zone

