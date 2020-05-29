#! /bin/bash
#========================================================
# Filename: deinstall.sh
#
# Description:
#	Deinstall script for the Jitsi module.
#
#========================================================

#remove installed file
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$REMOVE_FOLDER /srv/docker-jitsi-meet/
$REMOVE_FOLDER docker-jitsi-meet
rm installed

modulename="Jitsi"
$LOGGING -i "Removed module $modulename"
dialog --backtitle "Server Hardening" --msgbox "$modulename will be removed next docker compose" 0 0