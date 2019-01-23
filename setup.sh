#!/bin/bash

#========================================================
# Filename: setup.sh
#
# Description: TBA
#	SCRIPT_SOURCE_DIR inspired from:
#		https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
#
#========================================================

# --- GLB VARS ---
SCRIPT_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
export UTILS=${SCRIPT_SOURCE_DIR}/utils
export FILES=${SCRIPT_SOURCE_DIR}/files
export LOGGING=${UTILS}/logging.sh
export SUMMARY=${UTILS}/summary.sh
export REMOVE_FOLDER=${UTILS}/removeFolder.sh
export REMOVE_PACKAGE=${UTILS}/removePackage.sh
export CHECK_PACKAGE=${UTILS}/checkPackage.sh
export USER=${UTILS}/user.sh
export DOMAIN=""
export DOMAINIP=""
export MAILDOMAIN=""
export MAILUSERS=""
export SSHUSERS=""
export REMOVE_FLAG=""

# --- Control Flag Array ---
declare -A flag_=()
flag_["fw"]=0
flag_["dns"]=0
flag_["ssh"]=0
flag_["mail"]=0
flag_["web"]=0
check_flag=1

#========================================================
# _question
#
# sets the flag according to the user's input.
#

function _question {
	name=$1
	while true; do
		read -p "*** QUESTION *** Do you wish to perform action on ${name}  [y/n]?  " yn
		case $yn in
			[Yy]*)
				${LOGGING} -i "Action for ${name} set to true"
				flag_[${name}]=1
				break
				;;
			[Nn]*)
				${LOGGING} -i "Action for ${name} set to false (will skip it)."
				break
				;;
			*)
                        	echo "Please answer with yes or no."
				;;
		esac
	done
}

#========================================================
# _specificFlagSetup
#
# Collection function for all smaller user input functions. better overview and expandable
#

function _specificFlagSetup {
	${LOGGING} -i "Start the specific selection for single parts."
	_question "fw"
	_question "dns"
	_question "ssh"
	_question "mail"
	_question "web"
}


#========================================================
# _setupFlags
#
# sets the flags according to the user's input, so that he can then start the desired hardening process
#

function _setupFlags {
	 while true; do
		read -p "*** QUESTION *** Do you wish to perform a complete run (Firewall, DNS, SSH, Mail, Web)[y/n]?  " yn
                case $yn in
                        [Yy]*)
                                ${LOGGING} -i "Complete run set to true"
				flag_["fw"]=1
				flag_["dns"]=1
				flag_["ssh"]=1
				flag_["mail"]=1
				flag_["web"]=1
				break
                                ;;
                        [Nn]*)
                                ${LOGGING} -i "Complete run set to false."
				_specificFlagSetup
				break
				;;
			*)
				 echo "Please answer with yes or no."
				 ;;
		 esac
	 done
}

#========================================================
# _handleModFlag
#
# handles a MOD_FLAG in ${FILES} for for later re-runs
#
function _handleModFlag {
	if [ ${REMOVE_FLAG} -eq ${check_flag} ]; then
		if [ -f ${FILES}/MOD_FLAG ]; then
			rm ${FILES}/MOD_FLAG
		fi
	else
		${LOGGING} -i "Set modification Flag."
		touch ${FILES}/MOD_FLAG
	fi
}


function _spacer {
	component=$1
	echo -e "\n\n\n################################################\n"
	echo -e "		Start of $component"
	echo -e "\n################################################\n\n\n"
}


# --- MAIN ---
echo -e "\n Hello and welcome, \n"
echo -e "before we start, make sure you have these things ready for a complete run:"
echo -e "  - your external ip address from this server."
echo -e "  - a valid dns name."
echo -e "  - a user who is allowed to do sudo instead of the root user."
echo -e "  - enter all necessary ports in the fw.conf file in the files folder."
read -p "press enter to start or abort now with [CTRL] + [C]."
echo -e "\n"

if [ -f ${FILES}/MOD_FLAG ]; then
	while true; do
		read -p "*** QUESTION *** Modification Flag found. Please choose option: modify/uninstall [m|u]?  " mu
		case $mu in
			[Uu]*)
				${LOGGING} -i "Uninstall choosen"
				REMOVE_FLAG=1
				break
				;;
			[Mm]*)
				${LOGGING} -i "Modification choosen"
				REMOVE_FLAG=0
				break
				;;
			*)
				echo "Please answer with 'm' or 'u'."
				;;
		esac
	done
else
	${LOGGING} -i "No Modification Flag found. Seems to be the first run. Will start hardening now."
	REMOVE_FLAG=2
fi
_setupFlags
# --- Firewall Configuration ---
if [ ${flag_["fw"]} -eq ${check_flag} ]; then
	_spacer "Firewall"
	${SUMMARY} "<FW>" "Perform actions on Firewall"
	export FW=${SCRIPT_SOURCE_DIR}/fw
	if [ ${REMOVE_FLAG} -eq ${check_flag} ]; then
		${SUMMARY} "<FW>" "Perform uninstall on Firewall"
		${FW}/uninstall_fw.sh
	else
		${SUMMARY} "<FW>" "Perform install on Firewall"
		${FW}/fw.sh
	fi
	${SUMMARY} "<FW>" "Actions on Firewall Done"
fi

# --- DNS Configuration ---
if [ ${flag_["dns"]} -eq ${check_flag} ]; then
    echo -e "\n"
    read -p "Next up is DNS, press enter to continue"
    echo -e "\n"
	_spacer "DNS"
	${SUMMARY} "<DNS>" "Perform actions on DNS"
	export DNS=${SCRIPT_SOURCE_DIR}/dns
	if [ ${REMOVE_FLAG} -eq ${check_flag} ]; then
		${SUMMARY} "<DNS>" "Perform uninstall on DNS"
		${DNS}/uninstall_dns.sh
	else
		${SUMMARY} "<DNS>" "Perform install on DNS"
		${DNS}/dns.sh
	fi
	${SUMMARY} "<DNS>" "Actions on DNS Done"
fi

# --- SSH Configuration ---
if [ ${flag_["ssh"]} -eq ${check_flag} ]; then
    echo -e "\n"
    read -p "Next up is SSH, press enter to continue"
    echo -e "\n"
	_spacer "SSH"
	${SUMMARY} "<SSH>" "Perform actions on SSH"
	export SSH=${SCRIPT_SOURCE_DIR}/ssh
	if [ ${REMOVE_FLAG} -eq ${check_flag} ]; then
		${LOGGING} -i "SSH Remove is not intended. Skip."
	else
		${SUMMARY} "<SSH>" "Perform install on SSH"
		${SSH}/ssh.sh
	fi
	${SUMMARY} "<SSH>" "Actions on SSH Done"
fi

# --- Mail Configuration ---
if [ ${flag_["mail"]} -eq ${check_flag} ]; then
    echo -e "\n"
    read -p "Next up is Mail, press enter to continue"
    echo -e "\n"
	export MAIL=${SCRIPT_SOURCE_DIR}/mail
	${SUMMARY} "<Mail>" "Perform actions on Mail"
	if [ ${REMOVE_FLAG} -eq ${check_flag} ]; then
		${SUMMARY} "<Mail>" "Perform uninstall on Mail"
		_spacer "MAIL"
		${DNS}/uninstall_dns.sh
	else
		zero=0
		if [ ${flag_["dns"]} -eq ${zero} ]; then
			_spacer "DNS"
			${LOGGING} -w "Mail setup requires DNS config! Will start DNS Configurations now."
			export DNS=${SCRIPT_SOURCE_DIR}/dns
			${DNS}/dns.sh
		fi
		_spacer "MAIL"
		${SUMMARY} "<Mail>" "Perform install on Mail"
		${MAIL}/mail.sh
	fi
	${SUMMARY} "<Mail>" "Actions on Mail Done"
fi

# --- Web Configuration ---
if [ ${flag_["web"]} -eq ${check_flag} ]; then
    echo -e "\n"
    read -p "Next up is Web, press enter to continue"
    echo -e "\n"
	export WEB=${SCRIPT_SOURCE_DIR}/web
	${SUMMARY} "<Web>" "Perform actions on Web"
	if [ ${REMOVE_FLAG} -eq ${check_flag} ]; then
		${SUMMARY} "<Web>" "Perform uninstall on Web"
		_spacer "Web"
		${WEB}/uninstall_web.sh
	else
		zero=0
		if [ ${flag_["dns"]} -eq ${zero} ]; then
			_spacer "DNS"
			${LOGGING} -w "Web setup requires DNS config! Will start DNS Configurations now."
			export DNS=${SCRIPT_SOURCE_DIR}/dns
			${DNS}/dns.sh
		fi
		_spacer "Web"
		${SUMMARY} "<Web>" "Perform install on Web"
		${WEB}/web.sh
	fi
	${SUMMARY} "<Web>" "Actions on Web Done"
fi


_handleModFlag

${LOGGING} -i "Done. Finished with configurations
______________________________________________________________________________"


