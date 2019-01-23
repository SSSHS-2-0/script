#!/bin/bash

#========================================================
# Filename: installDNS.sh
#
# Description: Download named.root File and install DNS (unbound)
#
#========================================================


#========================================================
# install
#
# Download named.root File and install DNS (unbound)
#
function install {
  wget -O root.hints https://www.internic.net/domain/named.root > /dev/null 2>&1
  ${CHECK_PACKAGE} "unbound"
  systemctl enable unbound  > /dev/null 2>&1
  unbound-anchor
cat << EOF > /etc/unbound/unbound.conf
include: "/etc/unbound/unbound.conf.d/*.conf"

EOF

}

# --- MAIN ---

install
