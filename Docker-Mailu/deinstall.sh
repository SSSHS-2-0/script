#!/bin/bash

#========================================================
# Filename: deinstall.sh
#
# Description: 
#   Deinstall script for the Mailu module.
#
#========================================================

#remove installed file and inform user
rm $SCRIPT_SOURCE_DIR/mailu.env
rm /srv/docker-reverseproxy/conf.d/docker-webmail-*.conf
rm $(cat "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/domain)
$REMOVE_FOLDER /srv/docker-mailu/

rm installed

modulename="Mailu"
$LOGGING -i "Removed module $modulename"
dialog --backtitle "Server Hardening" --msgbox "$modulename will be removed next docker compose" 0 0