#! /bin/bash
#========================================================
# Filename: deinstall.sh
#
# Description:
#	  Deinstalls AppArmor Utils. AppArmor will remain as it is normally installed by default and removing may be risky.
#
#========================================================

#checking if AppArmor Utils is installed and uninstall it
$REMOVE_PACKAGE AppArmor
rm installed 
$LOGGING -i "Removed module AppArmor"
dialog --backtitle "$BACKTITLE" --msgbox "AppArmor removed" 0 0