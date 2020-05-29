#!/bin/bash

#========================================================
# Filename: install.sh
#
# Description: 
#   Install script for the Tor module.
#
#========================================================

# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}


modulename="Tor"

#get name of the relay and email of the user and put it in a file for later
exec 3>&1;
name=$(dialog --backtitle "$BACKTITLE" --inputbox "Tor Relay Name" 0 0 2>&1 1>&3);
exitcode=$?;
if (( ! $exitcode == $DIALOG_OK ))
then
    exit 0
fi
email=$(dialog --backtitle "$BACKTITLE" --inputbox "Contact email: " 0 0 2>&1 1>&3);
exitcode=$?;
if (( ! $exitcode == $DIALOG_OK ))
then
    exit 0
fi
exec 3>&-;
echo "relayName=\"$name\"" > tor_config
echo "contact=\"$email\"" >> tor_config
$LOGGING -i "Installed module $modulename"
dialog --backtitle "$BACKTITLE" --msgbox "$modulename will be installed in next docker compose" 0 0
touch installed