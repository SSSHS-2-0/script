#!/bin/bash

#========================================================
# Filename: checkPackage.sh
#
# Description:
#       checks if a package is already installed.
#	SCRIPT_SOURCE_DIR inspired from: 
#		https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
#
# Source: from SSSHS 1.0
#
#========================================================

# --- GLB VARS ---
PACKAGE_NAME=$1
ALLOW_TO_FAIL=$2
if [ -z $ALLOW_TO_FAIL ]; then 
	ALLOW_TO_FAIL=0
fi
#========================================================
# _checkParameter
#
# 

function _checkParameter {
	if [[ ${PACKAGE_NAME} == "" ]]; then
		_usage
		exit 1
	fi
	if [[ ${PACKAGE_NAME} == "-h" ]]; then
	       _usage	       
	       exit 0
       fi
}

#========================================================
# _usage
#
#

function _usage {
	echo "Usage:"
	echo "      $PACKAGE_NAME [PACKAGE_NAME]"
	exit 1
}

#========================================================
# _install
#
# Package installation with a progress bar. 
# Progress bar instpired by:
#	https://unix.stackexchange.com/questions/92919/progressbar-in-bash-to-visualize-the-time-to-wait
#
#

function _install {
	dialog --backtitle "$BACKTITLE" --infobox "Installing $PACKAGE_NAME ..." 0 0
	apt install $PACKAGE_NAME -y  > /dev/null 2>&1
	ret=$?
	if [ $ret -ne 0 ]; then
		$LOGGING -e "apt install $PACKAGE_NAME returned not 0. Maybe installing failed or starting service failed"
    	 if [ $ALLOW_TO_FAIL -ne 1 ]; then dialog --backtitle "$BACKTITLE" --msgbox "Failed to install package $1 please install manually" 0 0; fi
		exit 1
	fi
	$LOGGING -i "Installed $PACKAGE_NAME"

}


#========================================================
# _checkPackageExistence
#
# Checks if PACKAGE is already installed.
# If not it has the possibility to install it. 
#
#

function _checkPackageExistence {
	if [[ $(apt-cache search --names-only "^${PACKAGE_NAME}.*") == "" ]]; then
		$LOGGING -w "Package $PACKAGE_NAME does not exist"
		dialog --backtitle "$BACKTITLE" --msgbox "Package does not exist. Please check Package Name!" 0 0
		exit 1
	fi
	_install ${PACKAGE_NAME}
}

# --- MAIN ----

_checkParameter
_checkPackageExistence ${PACKAGE_NAME}