#!/bin/bash

#========================================================
# Filename: specificConfigurations.sh
#
# Description:
#       Sets specific configurations for the Ubuntu UncomplicatedFirewall.
#
#========================================================


# --- GLB VARS ---
FW_CONF=${FILES}/fw.conf


#========================================================
# _enableSSH
#
# enabels SSH - since without ssh no connection to the server would be possible anymore, 
# this connection is handled separately.
#

function _enableSSH {
	${LOGGING} -i "Activate SSH Connection for host '${HOSTNAME}'."
	ufw allow ssh > /dev/null 2>&1
}


#========================================================
# _checkConfigFile
#
# Checks if Firewall config file for specific configurations exists.
#

function _checkConfigFile {
	${LOGGING} -i "Looking for Firewall Config file for specific configurations"
	if [ -f ${FW_CONF} ]; then
		${LOGGING} -i "File Found. ${FW_CONF}"
	else 
		${LOGGING} -e "No Firewall file found under ${FILES}. Will Skip specific configurations."
		exit 1
	fi
}

# --- MAIN ---
_enableSSH
_checkConfigFile

while read line; do
	if [[ "$line" != *"#"* ]]; then
		activation=$(echo $line | cut -d '-' -f1 | tr -d '[:space:]')
		protocol=$(echo $line | cut -d '-' -f2 | tr -d '[:space:]')
		port=$(echo $line | cut -d '-' -f3 | tr -d '[:space:]')
		${LOGGING} -i "Working on '$activation $port/$protocol'."
		ufw $activation $port/$protocol > /dev/null 2>&1
	fi
done < ${FW_CONF}
${LOGGING} -i "Done Specific configurations."
