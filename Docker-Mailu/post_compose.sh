#!/bin/bash

#========================================================
# Filename: post_compose.sh
#
# Description: 
#   Sets the admin and initial password for Mailu
#
#========================================================

domain=$(cat "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/domain)
password=$($GENPW "mailu(admin@$domain)")

docker-compose exec admin flask mailu admin admin $domain $password