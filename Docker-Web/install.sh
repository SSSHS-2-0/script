#!/bin/bash

#========================================================
# Filename: install.sh
#
# Description: 
#   Install script for the Web module.
#
#========================================================

# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

modulename="Web"

#get domains
domains=($(cat $DOMAINLIST| cut -d: -f1))
emails=($(cat $DOMAINLIST| cut -d: -f2))

cat << EOF > /srv/docker-reverseproxy/conf.d/docker-web-upstream.conf
upstream apache {
    server webserver:80;
    
    keepalive 32;
    }
EOF
while read -r line; 
do     
    cat << EOF > /srv/docker-reverseproxy/conf.d/docker-web-$line-location.conf
location / {
            proxy_pass http://apache;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
EOF
done < <(for item in ${domains[*]}; do echo "$item"; done)
server_names+=";"

mkdir -p /srv/docker-web/virtual-host-files
#go trough domains
for index in ${!domains[*]}
do
    #add conf if it doesn't exist
    if [ ! -f /srv/docker-web/virtual-host-files/${domains[$index]}.conf ]; then

        cat << EOF >> /srv/docker-web/virtual-host-files/${domains[$index]}.conf
<VirtualHost *:80>
ServerAdmin ${emails[$index]}
ServerName ${domains[$index]}
ServerAlias www.${domains[$index]}
DocumentRoot /var/www/${domains[$index]}
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

    fi

    mkdir -p /var/www
    #add folder if default index.html if folder doesn't exist
    if [ ! -d /var/www/${domains[$index]} ]; then
    mkdir /var/www/${domains[$index]}
    cat << EOF >> /var/www/${domains[$index]}/index.html
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">
  <title>${domains[$index]}</title> 
</head>

<body>
    <h1>Hello World</h1>
  
</body>
</html>
EOF

    fi
done


echo "cd /var/www" > configure_container.sh

while read -r line; 
do     
    echo "chown -R \$USER:\$USER /var/www/$line" >> configure_container.sh
done < <(for item in ${domains[*]}; do echo "$item"; done)

echo "chmod -R 755 /var/www" >> configure_container.sh
echo "cd /etc/apache2/sites-available" >> configure_container.sh 

while read -r line; 
do     
    echo "a2ensite $line.conf" >> configure_container.sh
done < <(for item in ${domains[*]}; do echo "$item"; done)

echo "a2dissite 000-default.conf" >> configure_container.sh
echo "cd /etc/apache2" >> configure_container.sh
echo "cat << EOF >> apache2.conf" >> configure_container.sh
echo "    ServerName localhost" >> configure_container.sh
echo "EOF" >> configure_container.sh
echo "docker-php-ext-install mysqli" >> configure_container.sh
echo "service apache2 reload" >> configure_container.sh

touch installed
$LOGGING -i "Installed module $modulename"
dialog --backtitle "Server Hardening" --msgbox "$modulename will be installed in next docker compose" 0 0
