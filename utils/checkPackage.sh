#!/bin/bash

#========================================================
# Filename: checkPackage.sh
#
# Description:
#       checks if a package is already installed.
#	SCRIPT_SOURCE_DIR inspired from: 
#		https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
#
#========================================================

# --- GLB VARS ---
SCRIPT_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
LOGGING=${SCRIPT_SOURCE_DIR}/logging.sh
PACKAGE_NAME=$1

#========================================================
# _checkParameter
#
# 

function _checkParameter {
	if [[ ${PACKAGE_NAME} == "" ]]; then
		$LOGGING -e "Parameter 'PACKAGE_NAME' is empty!"
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
	echo "      $0 [PACKAGE_NAME]"
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
	package_name=$1
	${LOGGING} -i "Will install '${package_name}' now. Please wait..."
	while :;do
	       	echo -n "."
		sleep 1
	done & apt-get update > /dev/null 2>&1 && apt-get install ${package_name} -y  > /dev/null 2>&1
	kill $!; trap 'kill $!' SIGTERM; 
	echo
	${LOGGING} -i "Package '${package_name}' is installed now."
}


#========================================================
# _checkPackageExistence
#
# Checks if PACKAGE is already installed.
# If not it has the possibility to install it. 
#
#

function _checkPackageExistence {
	package_name=$1
	if [[ $(apt-cache search --names-only "^${package_name}.*") == "" ]]; then
		${LOGGING} -e "Package '${package_name}' does not seem to exist. Abort. Please check the name!"
		exit 1
	fi
	_install ${package_name}
}

# --- MAIN ----

_checkParameter
_checkPackageExistence ${PACKAGE_NAME}
