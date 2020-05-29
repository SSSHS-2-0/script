#!/bin/bash

#========================================================
# Filename: installDNS_unbound.sh
#
# Description: Download named.root File and install DNS (unbound)
# Changed Version of SSSHS 1.0
#========================================================


#========================================================
# install
#
# Download named.root File and install DNS (unbound)
#
function install {
  wget -O root.hints https://www.internic.net/domain/named.root > /dev/null 2>&1
  $CHECK_PACKAGE "unbound" 1
  ret=$?
	#if [ $ret -ne 0 ]; then
		#exit 1
	#fi
  systemctl enable unbound  > /dev/null 2>&1
  unbound-anchor
cat << EOF > /etc/unbound/unbound.conf
include: "/etc/unbound/unbound.conf.d/*.conf"

EOF

}

# --- MAIN ---

install
