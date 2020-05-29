#! /bin/bash
#========================================================
# Filename: install.sh
#
# Description:
#	  Installs AppArmor and loads some additional profiles.
#
#========================================================

#checking if AppArmor is installed and install it otherwise (should be installed by default)
$CHECK_PACKAGE "apparmor" 
ret=$?
if [ $ret -ne 0 ]; then
    exit 1
fi

$CHECK_PACKAGE "apparmor-utils" 
ret=$?
if [ $ret -ne 0 ]; then
    exit 1
fi
touch installed
$LOGGING -i "Installed module AppArmor"
dialog --backtitle "$BACKTITLE" --msgbox "AppArmor installed" 0 0