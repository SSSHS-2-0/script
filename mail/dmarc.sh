#!/bin/bash

#========================================================
# Filename: dmarc.sh
#
# Description: Opendmarc configuration for mailserver
#========================================================

echo -en "\n"
${LOGGING} -i "Configurting opendmarc"
echo -en "\n"

cat << EOF >> /etc/opendmarc.conf
AutoRestart Yes
AutoRestartRate 10/1h
PidFile /var/spool/postfix/opendmarc/opendmarc.pid
Socket local:/var/spool/postfix/opendmarc/opendmarc.sock
AuthservID $MAILDOMAIN
TrustedAuthservIDs $MAILDOMAIN
Syslog true
SyslogFacility mail
UMask 0002
UserID opendmarc:opendmarc
EOF

mkdir /var/spool/postfix/opendmarc
chown opendmarc:opendmarc /var/spool/postfix/opendmarc
sed -i '/PIDFile/d' /lib/systemd/system/opendmarc.service

echo -en "\n"
${LOGGING} -i "Reloading systemd units"
echo -en "\n"

systemctl daemon-reload

echo -en "\n"
${LOGGING} -i "Adding DNS records for opendmarc"
echo -en "\n"

echo "_dmarc IN TXT \"v=DMARC1\059 p=quarantine\059 sp=quarantine\059 adkim=r\059 aspf=r\059 fo=1\059 rf=afrf\059 rua=mailto:postmaster@$DOMAIN\"" >> /etc/nsd/zones/$DOMAIN.forward

echo -en "\n"
${LOGGING} -i "Integrating opendmarc into postfix"
echo -en "\n"

echo '#START OpendKIM & OpenDMARC' >> /etc/postfix/main.cf
postconf -e 'milter_protocol = 6'
postconf -e 'milter_default_action = accept'
postconf -e 'smtpd_milters = local:/opendkim/opendkim.sock, local:/opendmarc/opendmarc.sock'
postconf -e 'non_smtpd_milters = local:/opendkim/opendkim.sock, local:/opendmarc/opendmarc.sock'
echo '#END OpendKIM & OpenDMARC' >> /etc/postfix/main.cf
