#!/bin/bash

#========================================================
# Filename: logging.sh
#
# Description: 
#	handles logOutput and pastes stdout and stderr to a log file.
#	file is definde in variable LOG_FILE.
#
# Modifications: 
#	11.11.18 - init version
#
#========================================================

# --- GLB VARS ---
LOG_FILE="/var/log/ssshs2.log"

#========================================================
# _usage
#
# displayes the script possibilities
#
function _usage {
	echo "Usage:"
	echo "      $0 [-i|-e|-w] {ENTRY}"
	echo "        -i  Log-Level: <INFO>"
	echo "        -e  Log-Level: <ERROR>"
	echo "        -w  Log-Level: <WARNING>"
	echo "Info:"
	echo "      Log entry gots to LOG_FILE=$LOG_FILE"
}


#========================================================
# _checkLogFileExistence
#
# Checks if LOG_file exists, if not it will get created.
#
function _checkLogFileExistence {
	if [ ! -f ${LOG_FILE} ]; then
    		touch ${LOG_FILE}
	fi
}

#========================================================
# _createLogEntry
#
# pastes stdout and stderr to LOG_FILE. 
#
function _createLogEntry {
	log_level="$1"
	log_entry="$2"
	log_time_stamp="$(date)"
	echo "${log_level} - ${log_time_stamp} - ${log_entry}" >> ${LOG_FILE}
}

# --- MAIN ---
_checkLogFileExistence
if [ $# -eq 0 ]; then
	_usage
	exit 1
fi	
while getopts "i:e:w:h" arg; do
	case $arg in
		i)
			_createLogEntry "<INFO>" "$OPTARG"
			;;
		e)
			_createLogEntry "<ERROR>" "$OPTARG"
			;;
		w)
			_createLogEntry "<WARNING>" "$OPTARG"
			;;
		h)
			_usage
			;;

	esac
done