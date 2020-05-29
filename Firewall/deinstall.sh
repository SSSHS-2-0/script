#!/bin/bash

#========================================================
# Filename: deinstall.sh
#
# Description: 
#   Deinstall script for the firewall.
#
#========================================================

#Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

#double check
exec 3>&1;
result=$(dialog --backtitle "$BACKTITLE" \
        --cr-wrap \
        --yesno "Do you really want to deinstall ufw and delete associated files?" 0 0 2>&1 1>&3)
exitcode=$?;
exec 3>&-;
if (( $exitcode == $DIALOG_CANCEL ))
then
    exit           
fi

$REMOVE_PACKAGE "ufw"
$REMOVE_FOLDER "/etc/ufw"
rm installed
$LOGGING -i "Removed module firewall"
dialog --backtitle "$BACKTITLE" --msgbox "Module succesfully deinstalled" 0 0