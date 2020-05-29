#!/bin/bash

#========================================================
# Filename: deinstall.sh
#
# Description: 
#   Deinstall script for SSH.
#
#========================================================

# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

exec 3>&1;
result=$(dialog --backtitle "$BACKTITLE" \
        --cr-wrap \
        --yesno "Do you want to deinstall Openssh Server?" 0 0 2>&1 1>&3)
exitcode=$?;
exec 3>&-;
if (( $exitcode == $DIALOG_CANCEL ))
then
    exit           
fi
$REMOVE_PACKAGE openssh-server
$LOGGING -i "Removed module SSH Server"
rm installed

