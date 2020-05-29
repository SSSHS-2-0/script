 #!/bin/bash

#========================================================
# Filename: configForwardZoneDNS_nsd.sh
#
# Description: Configure the the Forward Zone
#
# Source: SSSHS 1.0
#
#========================================================

#========================================================
# create_forward_zone
#
# creates forward zone
#
function create_forward_zone {
	mkdir -p /etc/nsd/zones/
	cat << EOF >> /etc/nsd/zones/${domain_name}.forward

\$ORIGIN ${domain_name}.    ; default zone domain
\$TTL    86400               ; default time to live


@ IN SOA ns1.${domain_name}. ns2.${domain_name}. (
           ${serial}   ; serial number
           28800       ; Refresh
           7200        ; Retry
           1209600     ; Expire
           86400       ; Min TTL
           )

           NS      ns1.${domain_name}.
           NS      ns2.${domain_name}.
#          MX      10 mail.${domain_name}.

${domain_name}.	IN CAA 0 issue "letsencrypt.org"
${domain_name}. IN CAA 0 iodef "mailto:postmaster@${domain_name}"

  IN A  ${ipv4}
# IN TXT  "v=spf1 mx a ~all" 
ns1   IN A  ${ipv4}
ns2   IN A  ${ipv4}
www   IN A  ${ipv4}
*     IN A  ${ipv4}

EOF

}
 # --- MAIN ---

domain_name=$1
ipv4=$2
serial=`date +%Y%m%d%H`

create_forward_zone
