#!/bin/bash

#========================================================
# Filename: installDNS_nsd.sh
#
# Description: Install NSD
#
#========================================================

#========================================================
# install_nsd
#
# Download and install nsd and utils
#
function install_nsd {
  ${CHECK_PACKAGE} "nsd"
  systemctl enable nsd  > /dev/null 2>&1
  ${CHECK_PACKAGE} "ldnsutils" 
  nsd-control-setup  > /dev/null 2>&1
}

# --- MAIN ---

install_nsd
