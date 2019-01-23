#!/bin/bash

#========================================================
# Filename: uninstall_web.sh
#
# Description: 
#	performs uninstallation of the whole web part
#
#========================================================

# --- MAIN ---
${LOGGING} -i "Starting Uninstallation WEB part."
${REMOVE_PACKAGE} "nginx" "nginx-common" "nginx-core" "certbot" "python-certbot-nginx" "apache2"
${REMOVE_FOLDER} "/etc/nginx/" "/etc/apache2/"
${LOGGING} -i "Done Uninstallation of WEB part."
${SUMMARY} "<WEB>" "Uninstallation done."
