#!/bin/bash

#========================================================
# Filename: deinstall.sh
#
# Description: 
#   Deinstall script for the Web module.
#
#========================================================

# remove installed file and inform user
rm installed
$REMOVE_FOLDER /srv/docker-web
rm /srv/docker-reverseproxy/conf.d/docker-web-*.conf

modulename="Web"
$LOGGING -i "Removed module $modulename"
dialog --backtitle "Server Hardening" --msgbox "$modulename will be removed next docker compose" 0 0