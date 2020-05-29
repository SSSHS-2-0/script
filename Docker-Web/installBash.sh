#!/bin/bash

#========================================================
# Filename: installBash.sh
#
# Description: 
#   Installs Bash inside the nginx container as it is not installed by default.
#
#========================================================

apk update
apk upgrade
apk add bash
exit