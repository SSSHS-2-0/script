#!/bin/bash

#========================================================
# Filename: deinstall.sh
#
# Description: 
#   Deinstall script for the MySql module.
#
#========================================================

# remove files and inform user
rm $(cat "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/domain)
rm /srv/docker-reverseproxy/conf.d/docker-mysql-*.conf

rm installed

modulename="Mysql"
$LOGGING -i "Removed module $modulename"
dialog --backtitle "$BACKTITLE" --msgbox "$modulename will be removed next docker compose" 0 0