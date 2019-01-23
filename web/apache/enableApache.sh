#!/bin/bash

#========================================================
# Filename: enableApache.sh
#
# Description:
#       enables apache for a security hardening.
#
#========================================================

# --- GLB VARS ---

NGNIX_STATUS=$(systemctl status apache2 | grep Active | cut -d ':' -f2 | cut -d ' ' -f2 | tr -d '[:space:]')

# --- MAIN ---
if [ "${NGNIX_STATUS}" == "inactive" ]; then
	systemctl enable apache2 > /dev/null 2>&1
	systemctl start apache2 > /dev/null 2>&1
	${LOGGING} -i "Apache is enabled now."
else
	${LOGGING} -i "Apache is already activated."
fi
