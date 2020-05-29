#!/bin/bash

#========================================================
# Filename: install.sh
#
# Description: 
#   Install script for the Reverseproxy module.
#
#========================================================

# add installed file and inform user

modulename="Reverseproxy"
#let user add domains
$UTILS/domain_managment.sh
mkdir -p /srv/docker-reverseproxy/conf.d
mkdir -p /srv/docker-reverseproxy/certs
$LOGGING -i "Installed module $modulename"
dialog --backtitle "$BACKTITLE" --msgbox "$modulename will be installed in next docker compose" 0 0
touch installed