#!/bin/bash

#========================================================
# Filename: setup.sh
#
# Description: 
#   Prepares the docker-compose for the  MySql module.
#
#========================================================

#add the necessary lines to the docker-compose files
mkdir -p /srv/docker-mysql/mysql-data
PW=$($GENPW "mysql")

cat << EOF >> $SCRIPT_SOURCE_DIR/docker-compose.yml

  #mysql
  mysql-db-container:
    container_name: mysql-db
    image: mysql:latest
    restart: always
    command: --default-authentication-plugin=mysql_native_password
    environment:
      MYSQL_ROOT_PASSWORD: $PW
    ports:
      - 3306:3306
    volumes:
      - /srv/docker-mysql/mysql-data:/var/lib/mysql

  mysql-adminer-container:
    container_name: mysql-adminer
    image: adminer:latest
    restart: always
    environment:
      ADMINER_DEFAULT_SERVER: mysql-db
    ports:
      - 8080

EOF

unset PW