#!/bin/bash

#========================================================
# Filename: dkim.sh
#
# Description: DKIM configuration for mailserver
#========================================================

echo -en "\n"
${LOGGING} -i "Creating users for DKIM"
echo -en "\n"

useradd postfix  > /dev/null 2>&1
useradd opendkim   > /dev/null 2>&1
useradd opendmarc   > /dev/null 2>&1
usermod -a -G opendkim,opendmarc postfix
DATE=`date +%Y%m%d%H`

echo -en "\n"
${LOGGING} -i "Configuring opendkim"
echo -en "\n"

cat << EOF >> /etc/opendkim.conf
# This is a basic configuration that can easily be adapted to suit a standard
# installation. For more advanced options, see opendkim.conf(5) and/or
# /usr/share/doc/opendkim/examples/opendkim.conf.sample.

# Log to syslog
Syslog          yes
# Required to use local socket with MTAs that access the socket as a non-
# privileged user (e.g. Postfix)
UMask           002
# OpenDKIM user
# Remember to add user postfix to group opendkim
UserID          opendkim

# Map domains in From addresses to keys used to sign messages
KeyTable        /etc/opendkim/key.table
SigningTable        refile:/etc/opendkim/signing.table

# Hosts to ignore when verifying signatures
ExternalIgnoreList  /etc/opendkim/trusted.hosts
InternalHosts       /etc/opendkim/trusted.hosts

# Commonly-used options; the commented-out versions show the defaults.
Canonicalization    relaxed/simple
Mode            sv
SubDomains      no
#ADSPAction     continue
AutoRestart     no
AutoRestartRate     10/1M
Background      yes
DNSTimeout      5
SignatureAlgorithm  rsa-sha256

# Always oversign From (sign using actual From and a null From to prevent
# malicious signatures header fields (From and/or others) between the signer
# and the verifier.  From is oversigned by default in the Debian package
# because it is often the identity key used by reputation systems and thus
# somewhat security sensitive.
OversignHeaders     From
###UBUNTU 18.10
PidFile               /var/spool/postfix/opendkim/opendkim.pid
Socket          local:/var/spool/postfix/opendkim/opendkim.sock
EOF

chmod u=rw,go=r /etc/opendkim.conf
mkdir -p /etc/opendkim
mkdir -p /etc/opendkim/keys
chown -R opendkim:opendkim /etc/opendkim
chmod go-rw /etc/opendkim/keys
echo "*@$DOMAIN ${DOMAIN%.*}" > /etc/opendkim/signing.table
echo "${DOMAIN%.*} $DOMAIN:$DATE:/etc/opendkim/keys/${DOMAIN%.*}.private" > /etc/opendkim/key.table
echo "127.0.0.1
::1
localhost
$DOMAIN
$MAILDOMAIN" > /etc/opendkim/trusted.hosts

chown -R opendkim:opendkim /etc/opendkim
chmod -R go-rwx /etc/opendkim/keys

opendkim-genkey -b 2048 -h rsa-sha256 -r -s $DATE -d $DOMAIN -v
mv $DATE.private ${DOMAIN%.*}.private
mv $DATE.txt ${DOMAIN%.*}.txt
mv ${DOMAIN%.*}.* /etc/opendkim/keys/

chown -R opendkim:opendkim /etc/opendkim
chmod -R go-rw /etc/opendkim/keys

mkdir /var/spool/postfix/opendkim
chown opendkim:postfix /var/spool/postfix/opendkim

sed -i '/PIDFile/d' /lib/systemd/system/opendkim.service

echo -en "\n"
${LOGGING} -i "Reloading systemd units"
echo -en "\n"

systemctl daemon-reload

echo -en "\n"
${LOGGING} -i "Generating DNS records for opendkim"
echo -en "\n"

keypart1=`cat /etc/opendkim/keys/${DOMAIN%.*}.txt | awk -F "\"" '{ print $2}' | grep "p=" | cut -c3-100`
keypart2=`cat /etc/opendkim/keys/${DOMAIN%.*}.txt | awk -F "\"" '{ print $2}' | grep "p=" | cut -c101-1000`
keypart3=`cat /etc/opendkim/keys/${DOMAIN%.*}.txt | awk -F "\"" '{ print $2}' | grep "p=" -A2 | tail -n1`
echo "$DATE._domainkey       IN      TXT     (" >> /etc/nsd/zones/$DOMAIN.forward
echo "\"v=DKIM1\059 h=sha256\059 k=rsa\059 s=email\059 p=\"" >> /etc/nsd/zones/$DOMAIN.forward
echo "\"$keypart1\"" >> /etc/nsd/zones/$DOMAIN.forward
echo "\"$keypart2\"" >> /etc/nsd/zones/$DOMAIN.forward
echo "\"$keypart3\" )" >> /etc/nsd/zones/$DOMAIN.forward
echo "_adsp._domainkey       IN TXT \"dkim=all\"" >> /etc/nsd/zones/$DOMAIN.forward
