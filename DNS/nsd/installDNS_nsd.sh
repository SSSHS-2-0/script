#!/bin/bash

#========================================================
# Filename: installDNS_nsd.sh
#
# Description: Install NSD
#
# Changed Version of SSSHS 1.0
#
#========================================================

#========================================================
# install_nsd
#
# Download and install nsd and utils
#
function install_nsd {
  #no not use check_package
  $CHECK_PACKAGE "nsd" 1
  ret=$?
	#if [ $ret -ne 0 ]; then
    #ignore failing since the port nsd uses will be blocked
		#exit 1
	#fi
  systemctl enable nsd  > /dev/null 2>&1
  $CHECK_PACKAGE "ldnsutils" 1
  ret=$?
	#if [ $ret -ne 0 ]; then
	#	exit 1
	#fi
  nsd-control-setup  > /dev/null 2>&1
}

# --- MAIN ---

install_nsd
