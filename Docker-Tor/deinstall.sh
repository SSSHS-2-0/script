#!/bin/bash

#========================================================
# Filename: deinstall.sh
#
# Description: 
#   Deinstall script for the Tor module.
#
#========================================================

# remove installed file and inform user
rm installed
modulename="Tor"
$LOGGING -i "Removed module $modulename"
dialog --backtitle "$BACKTITLE" --msgbox "$modulename will be removed next docker compose" 0 0