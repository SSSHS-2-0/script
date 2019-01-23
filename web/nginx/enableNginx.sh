#!/bin/bash

#========================================================
# Filename: enableNginx.sh
#
# Description:
#       enables nginx for a security hardening.
#
#========================================================

# --- GLB VARS ---

NGNIX_STATUS=$(systemctl status nginx | grep Active | cut -d ':' -f2 | cut -d ' ' -f2 | tr -d '[:space:]')

# --- MAIN ---
if [ "${NGNIX_STATUS}" == "inactive" ]; then
	systemctl enable nginx > /dev/null 2>&1
	systemctl start nginx > /dev/null 2>&1
	${LOGGING} -i "Nginx is enabled now."
else
	${LOGGING} -i "Nginx is already activated."
fi
