#!/bin/bash

#========================================================
# Filename: ssh.sh
#
# Description: Main script to harden ssh daemon
#
#========================================================

# --- MAIN ---

# read domain from file
DOMAIN=$(<dns/domainname)
DOMAINIP=$(<dns/domainip)

# User handling
${LOGGING} -i "Doing user handling for SSH configuration"
${USER} ssh
SSHUSERS=$(<ssh/users)

# SSH keys
${LOGGING} -i "Generating SSH keys for users"
${SSH}/sshkeys.sh

# SSH daemon config
${LOGGING} -i "Hardening SSH daemon config"
${SSH}/config.sh

# Install sshguard packages
# ${LOGGING} -i "Installing sshguard package"
# ${CHECK_PACKAGE} sshguard

# Finishing up, restarting services
${LOGGING} -i "Finishing up, restarting services"
${SSH}/restart.sh

${LOGGING} -i "SSH daemon configuration complete."
