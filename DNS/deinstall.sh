#!/bin/bash

#========================================================
# Filename: uninstall_dns.sh
#
# Description:
#	performs uninstallation of the whole dns part
#
#========================================================
#Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

# --- MAIN ---
exec 3>&1;
result=$(dialog --backtitle "$BACKTITLE" \
        --cr-wrap \
        --yesno "Do you really want to deinstall DNS and delete associated files?" 0 0 2>&1 1>&3)
exitcode=$?;
exec 3>&-;
if (( $exitcode == $DIALOG_CANCEL ))
then
    exit           
fi

systemctl stop nsd 
systemctl stop unbound 
${REMOVE_PACKAGE} "sipcalc" 
${REMOVE_PACKAGE} "nsd" 
${REMOVE_PACKAGE} "ldnsutils" 
${REMOVE_PACKAGE} "unbound"
${REMOVE_FOLDER} "/etc/unbound/" "/etc/nsd/"
systemctl enable systemd-resolved
service systemd-resolved start
rm installed
$LOGGING -i "Removed module DNS"
dialog --backtitle "$BACKTITLE" --msgbox "DNS removed" 0 0