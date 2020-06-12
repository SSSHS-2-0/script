#!/bin/bash

#========================================================
# Filename: genPW.sh
#
# Description: generates new password
#
#========================================================

function gen_pw {
    password=$(openssl rand -hex 16)
}

module_name=$1
gen_pw

chmod 600 $PWLIST
echo "$module_name:$password" >> $PWLIST
chmod 400 $PWLIST
echo $password