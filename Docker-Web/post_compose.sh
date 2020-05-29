#!/bin/bash

#========================================================
# Filename: post_compose.sh
#
# Description: 
#   Will run a script inside the apache container to make some further configurations
#
#========================================================

# go inside the container
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
docker exec -i apache-php-webserver bash < configure_container.sh
