#!/bin/bash

#========================================================
# Filename: mail.sh
#
# Description: Main script to install mail server
# Arguments: $domain | A domain which was configured by the dns server and which (the domain itself or a subdomain) can be used for the mailserver
#
#========================================================

# --- MAIN ---

# ${LOGGING} -i "Starting mail configuration."

# Check domain (returns domain)
# User can choose this domain or a subdomain
# ${LOGGING} -i "Checking domain for mail server"
# ${MAIL}/checkDomain.sh
# read domain from file
DOMAIN=$(<dns/domainname)
MAILDOMAIN=mail.$(<dns/domainname)
DOMAINIP=$(<dns/domainip)

# Set up MX records
${LOGGING} -i "Setting up MX and SPF records in dns"
${MAIL}/dnsRecords.sh

# Install mailserver packages
${LOGGING} -i "Installing mailserver packages (postfix, mailutils, dovecot)"
DEBIAN_FRONTEND=noninteractive apt-get install postfix -y > /dev/null 2>&1
${CHECK_PACKAGE} postfix-pcre
${CHECK_PACKAGE} postfix-policyd-spf-python
${CHECK_PACKAGE} mailutils
${CHECK_PACKAGE} letsencrypt
${CHECK_PACKAGE} dovecot-core
${CHECK_PACKAGE} dovecot-imapd
${CHECK_PACKAGE} opendkim
${CHECK_PACKAGE} opendkim-tools
${CHECK_PACKAGE} opendmarc
${CHECK_PACKAGE} zip

# User handling
${LOGGING} -i "Configure Mail Hardening (TLS, SPF, DKIM, DMARC, dovecot, client certificate login) "
${USER} mail
MAILUSERS=$(<mail/users)

# Alias mapping
${LOGGING} -i "Mapping users to mail addresses"
${MAIL}/alias.sh

# Setting up TLS for mailserver
${LOGGING} -i "Setting up TLS with letsencrypt"
${MAIL}/tls.sh

# Setting up SPF
${LOGGING} -i "Setting up SPF (anti spam measure)"
${MAIL}/spf.sh

# Setting up DKIM
${LOGGING} -i "Setting up DKIM (anti spam measure)"
${MAIL}/dkim.sh

# Setting up DMARC
${LOGGING} -i "Setting up DMARC (anti spoofing measure)"
${MAIL}/dmarc.sh

# Configuring dovecot
${LOGGING} -i "Configuring dovecot as imap server"
${MAIL}/dovecot.sh

# Client certificate authentication
${LOGGING} -i "Configuring client certificate authentication"
${MAIL}/clientCertificate.sh

# Finishing up, restarting services
${LOGGING} -i "Finishing up, restarting services"
${MAIL}/restart.sh

${LOGGING} -i "Mailserver configuration complete."
