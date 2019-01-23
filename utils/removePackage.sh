#!/bin/bash

#========================================================
# Filename: removePackage.sh
#
# Description:
#       checks if a package is installed, if so it will uninstall it.
#	handling multiple parameters form:
#		https://www.linuxquestions.org/questions/linux-software-2/bash-pass-multiple-arguments-with-spaces-717268/
#
#========================================================

#========================================================
# _uninstall
#
# Package uninstallation. including autoremove.
#

function _uninstall {
	package_name=$1
	${LOGGING} -i "Will uninstall '${package_name}' now. Please wait..."
	apt-get purge ${package_name} --yes > /dev/null 2>&1
	apt autoremove --yes > /dev/null 2>&1
	${LOGGING} -i "Done uninstallation of package '${package_name}'."
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
		${LOGGING} -i "Package '${package_name}' found. Prepare for uninstall..."
		_uninstall ${package_name}
	else
		${LOGGING} -w "Package '${package_name}' not found. Skip uninstall..."
	fi
}

# --- MAIN ----

while [ ! -z "$1" ]; do
	_checkPackageExistence $1 
	shift
done
