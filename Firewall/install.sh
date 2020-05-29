#!/bin/bash

#========================================================
# Filename: install.sh
#
# Description: 
#   Install script for the firewall.
#
#========================================================

#Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

#check if ufw is installed
if ! $CHECK_PACKAGE "ufw"; then 
    exit 1
fi

dialog --backtitle "$BACKTITLE" --cr-wrap --msgbox "UFW is installed.\nIn the main menu execute \"Update Firewall\" to apply firewall rules" 0 0
touch installed

