#!/bin/bash

#========================================================
# Filename: spf.sh
#
# Description: SPF configuration for mailserver
#========================================================

echo -en "\n"
${LOGGING} -i "Adding SPF configuration to unbound"
echo -en "\n"

echo -en "\n"
${LOGGING} -i "Adding SPF configuration to postfix config"
echo -en "\n"

echo "policyd-spf  unix  -       n       n       -       0       spawn
    user=policyd-spf argv=/usr/bin/policyd-spf"  >> /etc/postfix/master.cf
postconf -e 'policyd-spf_time_limit = 3600'
postconf -e 'smtpd_recipient_restrictions = reject_unauth_pipelining, reject_non_fqdn_recipient, reject_unknown_recipient_domain, permit_mynetworks, check_policy_service unix:private/policyd-spf, reject_rbl_client zen.spamhaus.org, reject_rbl_client bl.spamcop.net'
