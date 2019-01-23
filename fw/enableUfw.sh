#!/bin/bash

#========================================================
# Filename: enableUfw.sh
#
# Description:
#       enables the Ubuntu UncomplicatedFirewall for a security hardening.
#
#========================================================

# --- GLB VARS ---

UFW_STATUS=$(ufw status | cut -d ':' -f2 | tr -d '[:space:]')

# --- MAIN ---
if [ "${UFW_STATUS}" == "inactive" ]; then
	yes | ufw enable > /dev/null 2>&1
	${LOGGING} -i "Ufw is enabled now."
else
	${LOGGING} -i "Ufw is already activated."
fi
