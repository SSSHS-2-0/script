#!/bin/bash

#========================================================
# Filename: deinstall.sh
#
# Description: 
#   Deinstall script for the Reverseproxy module.
#
#========================================================

# remove installed file and inform user

$REMOVE_FOLDER /srv/docker-reverseproxy
rm installed

modulename="Reverseproxy"
$LOGGING -i "Removed module $modulename"
dialog --backtitle "$BACKTITLE" --msgbox "$modulename will be removed next docker compose" 0 0