#!/bin/bash

#========================================================
# Filename: summary.sh
#
# Description: 
#	handles output for a summay and pastes stdout and stderr to a summary-file.
#	file and location is definde in variable SUMMRAY.
#
#========================================================

# --- GLB VARS ---
SUMMRAY="/var/log/security_hardening_summary.log"
ENTRY_TEXT=$2

#========================================================
# _usage
#
# displayes the script possibilities
#
function _usage {
	echo "Usage: $0 [SERVICE] [ENTRY]"
	echo "Info:"
	echo "      Summary entry gots to SUMMARY=$SUMMRAY"
}


#========================================================
# _checkSummrayFileExistence
#
# Checks if SUMMARY-file exists, if not it will get created.
#
function _checkSummrayFileExistence {
	if [ ! -f ${SUMMRAY} ]; then
    		touch ${SUMMRAY}
	fi
}

#========================================================
# _createSummaryEntry
#
# pastes stdout and stderr to SUMMARY. 
#
function _createSummaryEntry {
	sum_service="$1"
	sum_time_stamp="$(date)"
	echo "${sum_service} - ${sum_time_stamp} - ${ENTRY_TEXT}" 2>&1 | tee -a ${SUMMRAY}
}

# --- MAIN ---
_checkSummrayFileExistence
if [ $# -eq 0 ]; then
	_usage
	exit 1
fi	
if [ $# -eq 1 ]; then
	_usage
	exit 1
fi
_createSummaryEntry $1
