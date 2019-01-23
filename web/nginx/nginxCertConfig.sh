#!/bin/bash

#========================================================
# Filename: nginxCertConfig.sh
#
# Description:
#       prepares Cert after nginx is enabled and started.
#
#========================================================

#========================================================
# _setupCert
#
# generates cert and loads it for nginx
#

function _setupCert {
	output_pem="/etc/ssl/dh4096.pem"
	${LOGGING} -i "Start openssl to generate a ssl pem file."
	openssl dhparam -dsaparam -out ${output_pem} 4096
	${LOGGING} -i "Done. Your file is located here: ${output_pem}. Will start certbot."
	certbot certonly --agree-tos --nginx -n -d ${WEB_URL} -d www.${WEB_URL} -m admin@${WEB_URL}

}

# --- MAIN ---
WEB_URL=$1
if [ -z "${WEB_URL}" ]; then
        ${LOGGING} -e "WEB_URL not set! Abort!"
        exit 1
fi
_setupCert
