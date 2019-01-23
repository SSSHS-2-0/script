#!/bin/bash

#========================================================
# Filename: uninstall_mail.sh
#
# Description:
#       performs uninstallation of the whole mail part
#
#========================================================

# --- MAIN ---
${LOGGING} -i "Starting Uninstallation Mail part."
systemctl stop postfix
systemctl stop opendkim
systemctl stop opendmarc
systemctl stop dovecot
${REMOVE_PACKAGE} "postfix-pcre" "postfix-policyd-spf-python" "mailutils" "letsencrypt" "dovecot-coredovecot-imapd" "opendkim" "opendkim-tools" "opendmarc" 
${REMOVE_FOLDER} "/etc/postfix" "/etc/dovecot" "/etc/opendkim*" "etc/opendmarc*"
${LOGGING} -i "Done uninstallation of Mail part."
${SUMMARY} "<MAIL>" "Uninstallation done."
