#! /bin/bash
#========================================================
# Filename: install.sh
#
# Description:
#	Install script for the Jitsi module.
#
#========================================================

#add installed file and module name
touch installed
modulename="Jitsi"
$LOGGING -i "Installed module $modulename"
dialog --backtitle "Server Hardening" --msgbox "$modulename will be installed in next docker compose" 0 0
