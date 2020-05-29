#!/bin/bash

#========================================================
# Filename: install.sh
#
# Description: 
#   Install script for the MySql module.
#
#========================================================

# add installed file and inform user

modulename="Mysql"

$UTILS/select_domain.sh "Select domain for Adminer"
domain=$(cat domain)
if [  -z "$domain" ]; then
    dialog --backtitle "$BACKTITLE" --msgbox "You must select a domain" 0 0
    exit 1
fi

cat << EOF > /srv/docker-reverseproxy/conf.d/docker-mysql-$domain-location.conf
location /adminer {
            proxy_pass http://adminer;
    }
EOF

cat << EOF > /srv/docker-reverseproxy/conf.d/docker-mysql-upstream.conf
upstream adminer {
    server mysql-adminer-container:8080;
    
    keepalive 32;
    }
EOF
$LOGGING -i "Installed module $modulename"
dialog --backtitle "$BACKTITLE" --msgbox "$modulename will be installed in next docker compose" 0 0
touch installed