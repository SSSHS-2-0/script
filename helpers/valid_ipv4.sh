#!/bin/bash

#========================================================
# Filename: valid_ipv4.sh
#
# Description: Checks if user input is a ipv4 address
# SOURCE: https://gist.github.com/sveesible/d22ae619ddbc489591094b608aef7be2/c33ade6c79c972bb4777a1b6cc213e9dc6c19439
#
# Source: from SSSHS 1.0
#
#========================================================

#========================================================
# valid_ip
#
# Checks if user input is a valid ipv4 address
#

function valid_ip {
	read valid <<< $( awk -v ip="$input_ip" '
	BEGIN { n=split(ip, i,"."); e = 0;
	if (6 < length(ip) && length(ip) < 16 && n == 4 && i[4] > 0 && i[1] > 0){
			for(z in i){if (i[z] !~ /[0-9]{1,3}/ || i[z] >= 256){e=1;break;}}
	} else { e=1; } print(e);}')

	if [ $valid == 0 ]; then
		# Address is valid
			echo 1
	else
		# Address is not valid
			echo 0
	fi
}

# --- MAIN ---

input_ip=$1
valid_ip
