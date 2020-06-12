#!/bin/bash

#========================================================
# Filename: specificConfigurations.sh
#
# Description:
#       Sets specific configurations for the Ubuntu UncomplicatedFirewall.
#
# Source: SSSHS 1.0
#
#========================================================


# --- GLB VARS ---
FW_CONF="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/fw.conf


#========================================================
# _reset
#
# resets ufw and enables it again
#

function _reset {
	ufw --force reset  > /dev/null 2>&1
	ufw --force enable > /dev/null 2>&1
	ufw default deny incoming > /dev/null 2>&1
	ufw default allow outgoing > /dev/null 2>&1
}

#========================================================
# _enableSSH
#
# enabels SSH - since without ssh no connection to the server would be possible anymore, 
# this connection is handled separately.
#

function _enableSSH {
	ufw allow ssh > /dev/null 2>&1
}


#========================================================
# _checkConfigFile
#
# Checks if Firewall config file for specific configurations exists.
#

function _checkConfigFile {
	if [ ! -f ${FW_CONF} ]; then
		echo "no file found"
		exit 1
	fi
}

# --- MAIN ---
_reset
_enableSSH
_checkConfigFile

while read line; do
	if [[ "$line" != *"#"* ]]; then
		activation=$(echo $line | cut -d '-' -f1 | tr -d '[:space:]')
		protocol=$(echo $line | cut -d '-' -f2 | tr -d '[:space:]')
		port=$(echo $line | cut -d '-' -f3 | tr -d '[:space:]')
		ufw $activation $port/$protocol > /dev/null 2>&1
	else
		echo $line;
	fi
done < ${FW_CONF}