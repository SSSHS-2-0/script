#!/bin/bash

#========================================================
# Filename: setup.sh
#
# Description: 
#   Prepares the docker-compose for the  reverseproxy module.
#
#========================================================


#change to reverseproxy folder
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#get domains
domains=($(cat $DOMAINLIST| cut -d: -f1))

#creating nginx conf file
server_names="localhost "
while read -r line; 
do     
    server_names+="$line www.$line "
done < <(for item in ${domains[*]}; do echo "$item"; done)
server_names+=";"

cat << EOF > nginx.conf
events {}
http {

  include /etc/nginx/conf.d/*-upstream.conf;
EOF
while read -r line; 
do     
domain_name=$line
cat << EOF >>nginx.conf
  server {
        listen 443 ssl;
        server_name  localhost $domain_name www.$domain_name;
        ssl_prefer_server_ciphers on;
        ssl_protocols TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256;
        ssl_session_cache shared:SSL:50m;
        ssl_session_timeout 5m;
        ssl_certificate /etc/letsencrypt/live/${domains[0]}/fullchain.pem; # managed by Certbot
        ssl_certificate_key /etc/letsencrypt/live/${domains[0]}/privkey.pem; # managed by Certbot
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Xss-Protection "1; mode=block" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header Referrer-Policy "same-origin" always;
      
        include /etc/nginx/conf.d/*-$domain_name-location.conf;
    }
EOF
done < <(for item in ${domains[*]}; do echo "$item"; done)
cat << EOF >>nginx.conf
  server {
        listen 80;
        server_name  $server_names

        return 301 https://\$host\$request_uri;
    }
  }
EOF
#build docker image from Dockerfile
cp $DOMAINLIST .
docker build -t reverseproxy .
#add the necessary lines to the docker-compose files
cat << EOF >> $SCRIPT_SOURCE_DIR/docker-compose.yml

  #reverse proxy
  reverseproxy:
    container_name: reverseproxy
    image: reverseproxy
    restart: always   
    ports:
      - 80:80
      - 443:443
    restart: always
    volumes:
      - /srv/docker-reverseproxy/certs:/etc/letsencrypt
      - /srv/docker-reverseproxy/conf.d:/etc/nginx/conf.d

EOF