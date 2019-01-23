#!/bin/bash

#========================================================
# Filename: fw.sh
#
# Description: 
#	Performs uninstallation Ubuntu UncomplicatedFirewall.
#
#========================================================


# --- MAIN ---
${LOGGING} -i "Starting Uninstallation of Firewall."
${REMOVE_PACKAGE} "ufw"
${REMOVE_FOLDER} "/etc/ufw"
${LOGGING} -i "Done Uninstallation of Firewall."
${SUMMARY} "<FW>" "uninstallation done."
