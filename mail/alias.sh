#!/bin/bash

#========================================================
# Filename: alias.sh
#
# Description: Alias configuration for mailserver
#========================================================

echo -en "\n"
${LOGGING} -i "Adding users to alias and canonical file"
echo -en "\n"
echo >  /etc/aliases
echo >  /etc/postfix/canonical
for user in $MAILUSERS; do
    echo "$user: $user" >> /etc/aliases
    echo "$user@$MAILDOMAIN $user@$DOMAIN" >> /etc/postfix/canonical
    echo "$user:::::::" >> /etc/dovecot/users-external
done

echo -en "\n"
${LOGGING} -i "Adding supplementary postmaster user for dmarc reporting"
echo -en "\n"
echo "postmaster: root" >> /etc/aliases
echo "root@$MAILDOMAIN postmaster@$DOMAIN" >> /etc/postfix/canonical
newaliases
postmap /etc/postfix/canonical
postconf -e 'sender_canonical_maps = hash:/etc/postfix/canonical'
