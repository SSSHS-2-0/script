#!/bin/bash

#========================================================
# Filename: removePackage.sh
#
# Description:
#       checks if a package is installed, if so it will uninstall it.
#	handling multiple parameters form:
#		https://www.linuxquestions.org/questions/linux-software-2/bash-pass-multiple-arguments-with-spaces-717268/
#
# Source: from SSSHS 1.0
#
#========================================================

#========================================================
# _uninstall
#
# Package uninstallation. including autoremove.
#

function _uninstall {
	package_name=$1
	dialog --backtitle "$BACKTITLE" --infobox "Uninstalling $1 ..." 0 0
	apt purge ${package_name} --yes > /dev/null 2>&1
	apt autoremove --yes > /dev/null 2>&1
	$LOGGING -i "Removed $package_name"
}


#========================================================
# _checkPackageExistence
#
# Checks if PACKAGE is installed.
# If not it has the possibility to uninstall it. 
#

function _checkPackageExistence {
	package_name=$1
	if [[ $(dpkg -al | grep ${package_name}) != "" ]]; then
		_uninstall ${package_name}
	fi
	exit 1
}

# --- MAIN ----

while [ ! -z "$1" ]; do
	_checkPackageExistence $1 
	shift
done