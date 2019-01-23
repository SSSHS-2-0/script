#!/bin/bash

#========================================================
# Filename: dovecot.sh
#
# Description: Configuration for the dovecot service
#========================================================

echo -en "\n"
${LOGGING} -i "Configuring dovecot"
echo -en "\n"

echo -en "\n"
${LOGGING} -i "Configuring dovecot service"
echo -en "\n"
echo > /etc/dovecot/dovecot.conf
cat << EOF >> /etc/dovecot/dovecot.conf
## Dovecot configuration file
!include_try /usr/share/dovecot/protocols.d/*.protocol

!include conf.d/*.conf

auth default {
    mechanisms = plain login external
    user = root
    socket listen {
      client {
        path = /var/spool/postfix/private/auth
        mode = 0660
        user = postfix
        group = postfix
      }
    }
}
EOF

echo -en "\n"
${LOGGING} -i "Configuring dovecot SSL"
echo -en "\n"

echo > /etc/dovecot/conf.d/10-ssl.conf
cat << EOF >> /etc/dovecot/conf.d/10-ssl.conf
##
## SSL settings
##

ssl = yes

ssl_cert = </etc/letsencrypt/live/$MAILDOMAIN/fullchain.pem
ssl_key = </etc/letsencrypt/live/$MAILDOMAIN/privkey.pem

ssl_ca = </etc/ssl/certs/$DOMAIN.ca.crl.pem

ssl_client_ca_dir = /etc/ssl/certs

ssl_verify_client_cert = yes

ssl_cert_username_field = CN

# DH parameters length to use.
ssl_dh_parameters_length = 1024

# SSL protocols to use
ssl_protocols = !SSLv2 !SSLv3

# SSL ciphers to use
ssl_cipher_list = kEECDH:+kEECDH+SHA:kEDH:+kEDH+SHA:+kEDH+CAMELLIA:kECDH:+kECDH+SHA:kRSA:+kRSA+SHA:+kRSA+CAMELLIA:!aNULL:!eNULL:!SSLv2:!RC4:!MD5:!DES:!EXP:!SEED:!IDEA:!3DES

# Prefer the server's order of ciphers over client's.
ssl_prefer_server_ciphers = yes

# SSL extra options. Currently supported options are:
#   no_compression - Disable compression.
#   no_ticket - Disable SSL session tickets.
#ssl_options =
EOF

echo -en "\n"
${LOGGING} -i "Configuring dovecot SSL"
echo -en "\n"

echo > /etc/dovecot/conf.d/10-auth.conf
cat << EOF >> /etc/dovecot/conf.d/10-auth.conf
##
## Authentication processes
##

#disable_plaintext_auth = yes

auth_ssl_username_from_cert = yes

auth_mechanisms = plain login external

!include auth-system.conf.ext
!include auth-passwdfile.conf.ext
EOF

echo -en "\n"
${LOGGING} -i "Configuring external auth extension"
echo -en "\n"

echo > /etc/dovecot/conf.d/auth-passwdfile.conf.ext
cat << EOF >> /etc/dovecot/conf.d/auth-passwdfile.conf.ext
# Authentication for passwd-file users. Included from 10-auth.conf.
#
# passwd-like file with specified location.
# <doc/wiki/AuthDatabase.PasswdFile.txt>

passdb {
  driver = passwd-file
  # the PLAIN scheme prevents us from having to hash the empty string
  args = scheme=PLAIN username_format=%u /etc/dovecot/users-external

  # this option requires Dovecot 2.2.28 (or the patch), without it this setup
  # is insecure because it permits logins with the empty string as password
  mechanisms = external

  # explicitly permit empty passwords
  override_fields = nopassword
}

userdb {
  driver = passwd-file
  args = username_format=%u /etc/dovecot/users-external
}
EOF

echo -en "\n"
${LOGGING} -i "Configuring postfix for client certificates"
echo -en "\n"

echo "smtpd_tls_CAfile = /etc/ssl/certs/$DOMAIN.ca.crl.pem" >> /etc/postfix/main.cf
echo "tls_append_default_CA = no" >> /etc/postfix/main.cf

postconf -e 'smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, permit_tls_all_clientcerts, reject_unauth_destination'

sed -i '/.*-o syslog_name=postfix\/submission.*/a \ \ -o smtpd_tls_ask_ccert=yes' /etc/postfix/master.cf
sed -i '/.*-o syslog_name=postfix\/submission.*/a \ \ -o smtpd_sasl_auth_enable=yes' /etc/postfix/master.cf
sed -i '/.*-o syslog_name=postfix\/submission.*/a \ \ -o smtpd_tls_security_level=encrypt' /etc/postfix/master.cf
