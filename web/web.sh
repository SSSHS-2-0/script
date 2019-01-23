#!/bin/bash

#========================================================
# Filename: web.sh
#
# Description:
#	configures a nginx for a security hardening.
#	SCRIPT_SOURCE_DIR inspired from:
#		https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
#
#========================================================

#========================================================
# _validateURL
#
# Checks if the URL entered by a user is valid. Soft checks.
#

function _validateURL {
	answer=$1
	if [[ ${answer} == "" ]]; then
		echo "You typed nothing..."
		_enterURL
	elif [[ ${answer} =~ ^www.*$ ]]; then
		echo "you have to type the url without www."
		_enterURL
	elif [[ ${answer} =~ ^([A-Za-z0-9])*\.[A-Za-z]{2,3}$ ]]; then
		export WEB_URL=${answer}
		${LOGGING} -i "Starting nginx Configurations."
		${WEB}/nginx/enableNginx.sh
		if [ $? -eq 0 ]; then
			${LOGGING} -i "Start Nginx Hardening. (TLS, redirect http->https, secuirty headers, no server token, timeouts)"
			${WEB}/nginx/nginxCertConfig.sh ${WEB_URL}
			${WEB}/nginx/configureNginx.sh ${WEB_URL}
		else
			${LOGGING} -w "It seems there was an Error! abort."
			exit 1
		fi
			${LOGGING} -i "Starting apache Configurations."
			${WEB}/apache/enableApache.sh
		if [ $? -eq 0 ]; then
			${WEB}/apache/configureApache.sh ${WEB_URL}
		else
			${LOGGING} -w "It seems there was an Error! abort."
			exit 1
		fi
	else
		${LOGGING} -w "URL seems not valid."
		_enterURL
fi
}

#========================================================
# _enterURL
#
# Function that accepts userinuput for handling URL to generate certs
#

function _enterURL {
    # read url from file
    answer=$(<dns/domainname)
    _validateURL ${answer}
}


# --- MAIN ---
${LOGGING} -i "Starting WEB Configurations."
${CHECK_PACKAGE} "nginx"
${CHECK_PACKAGE} "certbot"
${CHECK_PACKAGE} "python-certbot-nginx"
${CHECK_PACKAGE} "apache2"
_enterURL

# FINAL MASSAGE
echo -en "\n\n"
${LOGGING} -i "This is your friendly reminder to download your secrets! (rsync needs to be installed on your client):"
echo -en "\n"
cat download_commands.txt
echo -en "\n\n"
rm download_commands.txt
