#!/bin/bash

#========================================================
# Filename: enrtypoint.sh
#
# Description: 
#   This is needed for the reverse proxy to run the certbot before the nginx
#
#========================================================

#get all the domains from the list
domains=($(cat domains.list| cut -d: -f1))
emails=($(cat domains.list| cut -d: -f2))

#concatinate the command to start the Certbot
certs=' '

for index in ${!domains[*]}
do
    temp="-d ${domains[$index]} -d www.${domains[$index]} -m ${emails[$index]} "
    certs+=$temp
done

#make the pem file
#output_pem="/etc/ssl/dh4096.pem"
#openssl dhparam -dsaparam -out ${output_pem} 4096

#start the Certbot for all domains
certbot certonly --standalone --agree-tos --expand -n $certs

/usr/sbin/nginx -g "daemon off;"
