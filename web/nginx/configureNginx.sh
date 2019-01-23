#!/bin/bash

#========================================================
# Filename: configureNginx.sh
#
# Description:
#       configures the nginx conf and also a specific configuration file according to WEB_URL
#
#========================================================


#========================================================
# _configureNginxConf
#
# configures nginx according to this prepared template in the function
#

function _configureNginxConf {
	${LOGGING} -i "Will start to setup nginx.conf file"
cat << EOF > /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
  	# multi_accept on;
}

http {
	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	server_tokens off;

	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

	gzip on;

	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
}


EOF
	${LOGGING} -i "Done. Your file is located under '/etc/nginx/nginx.conf'."
}

#========================================================
# _specificConfigurations
#
# configures a specific conf file for WEB_URL
#

function _specificConfigurations {
	${LOGGING} -i "Will start specific Configurations"
	cat << EOF > /etc/nginx/conf.d/${WEB_URL}.conf
server {
	listen 443 ssl;
	listen [::]:443 ssl;
	server_name ${WEB_URL} www.${WEB_URL} default_server;

	ssl_prefer_server_ciphers on;
	ssl_protocols TLSv1.1 TLSv1.2;
	ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256;

	ssl_session_cache shared:SSL:50m;
	ssl_session_timeout 5m;

	ssl_certificate /etc/letsencrypt/live/${WEB_URL}/fullchain.pem; # managed by Certbot
	ssl_certificate_key /etc/letsencrypt/live/${WEB_URL}/privkey.pem; # managed by Certbot

	ssl_dhparam /etc/ssl/dh4096.pem;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Xss-Protection "1; mode=block" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header Referrer-Policy "same-origin" always;

	access_log /var/log/nginx/${WEB_URL}_ssl_access.log;
	error_log /var/log/nginx/${WEB_URL}_ssl_error.log;

	location / {
    		proxy_set_header X-Real-IP       \$remote_addr;
		proxy_set_header X-Forwarded-For \$remote_addr;
    		proxy_set_header Host            \$host;
    		proxy_pass http://127.0.0.1:8080;
	}
}

server {
	listen 80;
	listen [::]:80;
	server_name ${WEB_URL} www.${WEB_URL} default_server;

	access_log /var/log/nginx/${WEB_URL}_access.log;
	error_log /var/log/nginx/${WEB_URL}_error.log;

	return 301 https://\$host\$request_uri;
}
EOF
	${LOGGING} -i "Done. Your file is located under '/etc/nginx/conf.d/${WEB_URL}.conf'."
}

# --- MAIN ---

WEB_URL=$1
if [ -z "${WEB_URL}" ]; then
        ${LOGGING} -e "WEB_URL not set! Abort!"
        exit 1
fi

if [ -f /etc/nginx/sites-enabled/default ]; then
    ${LOGGING} -i "Will remove default sites of nginx"
    rm /etc/nginx/sites-enabled/default
fi
_configureNginxConf
_specificConfigurations

${LOGGING} -i "Will check Syntax and activate."
nginx -t
systemctl reload nginx
