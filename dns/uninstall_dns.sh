#!/bin/bash

#========================================================
# Filename: uninstall_dns.sh
#
# Description:
#	performs uninstallation of the whole dns part
#
#========================================================

# --- MAIN ---
${LOGGING} -i "Starting Uninstallation DNS part."
systemctl stop nsd 
systemctl stop unbound 
${REMOVE_PACKAGE} "sipcalc" "nsd" "ldnsutils" "unbound"
${REMOVE_FOLDER} "/etc/unbound/" "/etc/nsd/"
systemctl start systemd-resolved
${LOGGING} -i "Done uninstallation of DNS part."
${SUMMARY} "<DNS>" "Uninstallation done."
