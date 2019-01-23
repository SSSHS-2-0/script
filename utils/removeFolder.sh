#!/bin/bash

#========================================================
# Filename: removeFolder.sh
#
# Description:
#       checks if a folder exists and removes it if so.
#	handling multiple parameters form:
#		https://www.linuxquestions.org/questions/linux-software-2/bash-pass-multiple-arguments-with-spaces-717268/
#
#========================================================

#========================================================
# _checkAndRemoveFolder
#
# checks if folder exists and if it does, it will be removed
# 

function _checkAndRemoveFolder {
	dir=$1
	if [ -d "$dir" ]; then
		${LOGGING} -i "Will remove folder and all Subfolder of Directory '$dir'."
		rm -rf ${dir}
	fi
}

# --- MAIN ----

while [ ! -z "$1" ]; do 
	_checkAndRemoveFolder $1 
	shift 
done
