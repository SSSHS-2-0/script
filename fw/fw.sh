#!/bin/bash

#========================================================
# Filename: fw.sh
#
# Description: 
#	configures the Ubuntu UncomplicatedFirewall for a security hardening.
#	SCRIPT_SOURCE_DIR inspired from:
#		https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
#	Specific configurations for the Ubuntu UncomplicatedFirewall are placed in FILES-Folder in fw.conf file.
#
#========================================================


# --- MAIN ---
${LOGGING} -i "Starting Firewall Configurations."
${CHECK_PACKAGE} "ufw"
${FW}/enableUfw.sh
${SUMMARY} "<FW>" "UFW enable done."
if [ $? -eq 0 ]; then
	${LOGGING} -i "Start Firewall Hardening. (close all non relevant ports)"
	${FW}/controllTraffic.sh
	${SUMMARY} "<FW>" "Traffic controll done."
	if [ $? -eq 0 ]; then
		${FW}/specificConfigurations.sh
		${SUMMARY} "<FW>" "Specific Configurations of UFW done."
	else
		${LOGGING} -w "Traffic controll not enabled. Skipping specific configurations."
	fi
else
	${LOGGING} -w "It seems there was an Error! abort."
	exit 1
fi
${LOGGING} -i "Firewall Configurations done." 
ufw status
${SUMMARY} "<FW>" "UFW Configurations done."
