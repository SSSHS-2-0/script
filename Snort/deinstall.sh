#!/bin/bash

#========================================================
# Filename: deinstall.sh
#
# Description: 
#   Deinstall script for Snort.
#
#========================================================

#remove all the packages and inform user
rm installed
$REMOVE_PACKAGE "snort"
$REMOVE_PACKAGE "libpcap-dev"
$REMOVE_PACKAGE "bison"
$REMOVE_PACKAGE "flex"
modulename="Snort"
$LOGGING -i "Removed module $modulename"
dialog --backtitle "Server Hardening" --msgbox "$modulename was removed" 0 0