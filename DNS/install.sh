#!/bin/bash

#========================================================
# Filename: install.sh
#
# Description: 
#	Main Script to install & configure DNS Server
#
# Changed Version of SSSHS 1.0
#========================================================

#Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

#should be already in the correct directory, just to be sure
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#This function sadly needs to be in every script you want to check if a sub script was sucessfull
function check {
        if ! eval "./$1"; then
            exit 1
        fi
}
#========================================================
# initial_unbound
#
# installs initially unbound for localhost only usage
#

function initial_unbound {
    dialog --backtitle "$BACKTITLE" --msgbox "We install two DNS Server, one for internal DNS requests (for this server and/or home clients) and one authoritative DNS Server for your domain" 0 0
    dialog --backtitle "$BACKTITLE" --msgbox "We install the basic configuration for unbound - we come back to it later" 0 0
	localhost_only=1
    check "dns_unbound.sh $localhost_only"
}
#========================================================
# domain_info
#
# informs the user about domains
#
function domain_info {
    dialog --backtitle "$BACKTITLE" --cr-wrap --msgbox "$(cat domain_info.txt)" 0 0
    }
#========================================================
# get_domain_name
#
# get's domain name from user
#
function get_domain_name {
    $UTILS/domain_managment.sh "DNS"
	if [[ ! -s $DOMAINLIST ]]
	then
		dialog --msgbox "You need your own domain... exiting" 0 0
		exit 0
	fi
}
#========================================================
# get_check_ipv4
#
# gets ipv4 from user
#
function get_check_ipv4 {
	ipv4=$($UTILS/getIpv4.sh)
	if [ $($UTILS/getAllIpv4.sh | wc -l) -gt 1 ] ; then
		result=$($UTILS/dialog_chooseIp.sh 4)
		if (( $result == "canceled" ))
		then
			dialog  --backtitle "$BACKTITLE"  --msgbox "exiting..." 0 0
			exit 0
		else
			ipv4=$result
			echo ${ipv4} > domainip
		fi
	fi
	DOMAINIP=$ipv4
	revIpv4=$($UTILS/revIpv4.sh ${ipv4})
}
#========================================================
# get_check_ipv6
#
# gets ipv6 from user (if available)
#
function get_check_ipv6 {
	ipv6=$($UTILS/getIpv6.sh)
	if [ $($UTILS/getAllIpv6.sh | wc -l) -gt 1 ] ; then

		result=$($UTILS/dialog_chooseIp.sh 6)
		if (( $result == $canceled ))
		then
			dialog  --backtitle "$BACKTITLE"  --msgbox "exiting..." 0 0
			exit 0			
		else
			ipv6=$result
		fi
	fi
}
#========================================================
# install_nsd
#
# installs NSD with the information provided by user
#
function install_nsd {
	ret=$($CHECK_PACKAGE sipcalc)
	if [ $ret -ne 0 ]; then
		exit 1
	fi
	get_check_ipv4
	get_check_ipv6

	check "dns_nsd.sh \"$(cat $DOMAINLIST| cut -d: -f1)\" $ipv4 $revIpv4 $ipv6"
}

#========================================================
# reconfig_unbound
#
# givs the user possiblity to use the unbound DNS in his internal network
#
function reconfig_unbound {
if [ $($UTILS/getAllIpv4.sh | wc -l) -gt 1 ] 
	then
		exec 3>&1
		result=$(dialog --backtitle "$BACKTITLE" --no-items --radiolist "Do you rent this server or is it in your internal network area?" 0 0 0 "intern" off "renting" on)
		exitcode=$?
		exec 3>&-
		if (( $exitcode == $DIALOG_OK ))
		then
			if (( $result == "intern" ))
			then
				exec 3>&1
				result=$(dialog --backtitle "$BACKTITLE" --yesno "Do you want to use this DNS in your internal network area?" 0 0)
				exitcode=$?
				exec 3>&-
				if (( $exitcode == $DIALOG_OK ))
				then
					local_ipv4=$($UTILS/getAllIpv4.sh | grep -v $ipv4)

					if [ $($UTILS/getAllIpv4.sh | wc -l) -gt 2 ] ; then
						local_ipv4=$($UTILS/dialog_chooseIp.sh 4 $ipv4)
					fi

					local_ipv6=$($UTILS/helpers/getAllIpv6.sh | grep -v $ipv6)

					if [ $($UTILS/helpers/getAllIpv6.sh | wc -l) -gt 2 ] ; then
						local_ipv6=$($UTILS/helpers/dialog_chooseIp.sh 6 $ipv6)
					fi

					localhost_only=0
					check "dns_unbound.sh $localhost_only  $local_ipv4 $local_ipv6"
				fi
			fi
		else
			dialog  --backtitle "$BACKTITLE"  --msgbox "exiting..."  0 0
			exit 0
		fi
	fi
	check "unbound/testDNS_unbound.sh"
}

# --- MAIN ---
initial_unbound
domain_info
get_domain_name
install_nsd
reconfig_unbound
$LOGGING -i "Installed module DNS"
dialog  --backtitle "$BACKTITLE"  --msgbox "DNS successfully installed and configured"  0 0
touch installed
