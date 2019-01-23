#!/bin/bash

#========================================================
# Filename: tls.sh
#
# Description: Configure TLS settings for postfix
#========================================================

echo -en "\n"
${LOGGING} -i "Running letsencrypt to obtain a certificate"
echo -en "\n"
${CHECK_PACKAGE} "certbot"
certbot certonly --agree-tos --standalone -n -m postmaster@$DOMAIN -d $MAILDOMAIN


echo -en "\n"
${LOGGING} -i "Configuring TLS for postfix"
echo -en "\n"

postconf -e 'myhostname = '$MAILDOMAIN''
postconf -e 'mydomain = '$DOMAIN''
postconf -e 'mydestination = $myhostname, $mydomain, '$MAILDOMAIN', localhost.'$DOMAIN', localhost'

postconf -e 'smtpd_use_tls = yes'
postconf -e 'smtpd_tls_cert_file = /etc/letsencrypt/live/'$MAILDOMAIN'/fullchain.pem'
postconf -e 'smtpd_tls_key_file = /etc/letsencrypt/live/'$MAILDOMAIN'/privkey.pem'
postconf -e 'smtp_tls_security_level = may'
postconf -e 'smtp_tls_note_starttls_offer = yes'
postconf -e 'smtp_tls_loglevel = 1'
postconf -e 'smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_tls_session_cache'
echo "###https://access.redhat.com/articles/1468593" >> /etc/postfix/main.cf
postconf -e 'smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1'
postconf -e 'smtpd_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1'
postconf -e 'smtp_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1'
postconf -e 'smtp_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1'
postconf -e 'smtp_tls_exclude_ciphers = EXP, MEDIUM, LOW, DES, 3DES, SSLv2'
postconf -e 'smtpd_tls_exclude_ciphers = EXP, MEDIUM, LOW, DES, 3DES, SSLv2'
postconf -e 'tls_high_cipherlist = kEECDH:+kEECDH+SHA:kEDH:+kEDH+SHA:+kEDH+CAMELLIA:kECDH:+kECDH+SHA:kRSA:+kRSA+SHA:+kRSA+CAMELLIA:!aNULL:!eNULL:!SSLv2:!RC4:!MD5:!DES:!EXP:!SEED:!IDEA:!3DES:!SHA'
postconf -e 'tls_preempt_cipherlist      = yes'
postconf -e 'smtp_tls_ciphers = high'
postconf -e 'smtpd_tls_ciphers = high'

echo -en "\n"
${LOGGING} -i "TLS configuration for postfix complete"
echo -en "\n"

echo -en "\n"
${LOGGING} -i "Restarting postfix service"
echo -en "\n"
systemctl restart postfix
