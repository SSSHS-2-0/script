#!/bin/bash

#========================================================
# Filename: configureApache.sh
#
# Description:
#       configures the apache for a security hardened apache
#
#========================================================

# --- GLB VARS ---
WEB_URL=$1
URL_FOLDER="/var/www/$(echo ${WEB_URL} | cut -d '.' -f1)"


#========================================================
# _setupDefaultWebpage
#
# sets up a default mini web page - that shows that hargedning works. can be replaced after configuration is done.
#

function _setupDefaultWebpage {
	${LOGGING} -i "Will Setup a default mini webpage."
	cat << EOF > ${URL_FOLDER}/index.html
<!doctype html>
	<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="x-ua-compatible" content="ie=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<title>Projekt 1</title>
	</head>
	<body>
		<p style="text-align:center;">It works!</p>
	</body>
</html>
EOF
}

#========================================================
# _setupPortConfiguration
#
# Portfile
#

function _setupPortConfiguration {
	 ${LOGGING} -i "Will Setup a seperate ports.conf file."
	cat << EOF > /etc/apache2/ports.conf
Listen 8080
# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF
}


#========================================================
# _setupAvaibleSites
#
# Avaible Sites VirtualHost configurations
#

function _setupAvaibleSites {
	${LOGGING} -i "Will Setup avaible sites."
	cat << EOF > /etc/apache2/sites-available/${WEB_URL}.conf

<VirtualHost 127.0.0.1:8080>
	ServerName ${WEB_URL}
	ServerName www.${WEB_URL}
	ServerAdmin webmaster@${WEB_URL}
	DocumentRoot ${URL_FOLDER}

	#LogLevel info ssl:warn

	ErrorLog  \${APACHE_LOG_DIR}/ismu.ga_error.log
	CustomLog \${APACHE_LOG_DIR}/ismu.ga_access.log combined
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF
	ln -s /etc/apache2/sites-available/${WEB_URL}.conf /etc/apache2/sites-enabled/${WEB_URL}.conf
}

#========================================================
# _configureApache
#
# collection function for better overview
#

function _configureApache {
	_setupDefaultWebpage
	_setupPortConfiguration
	_setupAvaibleSites
}

# --- MAIN ---
if [ -z "${WEB_URL}" ]; then
	${LOGGING} -e "WEB_URL not set! Abort!"
	exit 1
fi
mkdir -p ${URL_FOLDER}
if [ -h /etc/apache2/sites-enabled/000-default.conf ]; then
	${LOGGING} -i "Found enabled default site, removing symlink"
	rm /etc/apache2/sites-enabled/000-default.conf
fi

_configureApache

${LOGGING} -i "Will check Syntax and activate."
apache2ctl configtest
systemctl restart apache2
