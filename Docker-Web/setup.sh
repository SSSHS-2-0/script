#!/bin/bash

#========================================================
# Filename: setup.sh
#
# Description: 
#   Prepares the docker-compose for the  Web module.
#
#========================================================


cat << EOF >> $SCRIPT_SOURCE_DIR/docker-compose.yml

  #webserver
  webserver:
    image: php:7.2-apache
    container_name: apache-php-webserver
    hostname: localhost
    restart: always
    expose:
      - "80"
    volumes:
      - /var/www:/var/www
      - /srv/docker-web/virtual-host-files:/etc/apache2/sites-available

EOF


