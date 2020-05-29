#!/bin/bash

#========================================================
# Filename: setup.sh
#
# Description: 
#   Prepares the docker-compose for the  Tor module.
#
#========================================================

#get the information from the file
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. $DIR/tor_config

#add the necessary lines to the docker-compose files
cat << EOF >> $SCRIPT_SOURCE_DIR/docker-compose.yml

  #tor relay
  relay:
    container_name: relay
    image: chriswayg/tor-server
    restart: always
    network_mode: host  
    environment:
      TOR_NICKNAME: ${relayName}
      CONTACT_EMAIL: ${contact}

EOF
