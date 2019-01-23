#!/bin/bash

#========================================================
# Filename: clientCertificate.sh
#
# Description: Generate client certificates for mailserver
#========================================================

wget --quiet https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.5/EasyRSA-nix-3.0.5.tgz
tar xf EasyRSA-nix-3.0.5.tgz
rm EasyRSA-nix-3.0.5.tgz
cd EasyRSA-3.0.5

echo -en "\n"
${LOGGING} -i "Generating certificate authority, please enter a passphrase when promted:"
echo -en "\n"
read -sp "Pre-Enter New CA Key Passphrase: " ca_password
echo -en "\n"
./easyrsa --batch init-pki
	echo 'set_var EASYRSA_DN      "cn_only"' > vars
	echo 'set_var EASYRSA_REQ_CN          '\""$DOMAIN\""'' >> vars
./easyrsa --keysize=4096 --batch build-ca
./easyrsa --batch gen-crl 2>/dev/null
cat pki/ca.crt pki/crl.pem > /etc/ssl/certs/$DOMAIN.ca.crl.pem
cp pki/private/ca.key /etc/ssl/private/$DOMAIN.ca.key
cd -
rm -r EasyRSA-3.0.5

for user in $MAILUSERS; do
echo "CA ($DOMAIN) passphrase: $ca_password" >> /home/$user/passwords.txt
	echo -en "\n"
	${LOGGING} -i "Generating key and certificate for user $user"
	${LOGGING} -i "IMPORTANT - make sure you remember ALL the passphrases! You can download your certificate and key after the setup. - IMPORTANT"
	echo -en "\n"

	openssl genrsa -out $user.key 4096 2>/dev/null
cat > openssl.cnf <<EOF
[ req ]
prompt = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
CN = $user
emailAddress = $user@$DOMAIN
EOF

	openssl req -new -config openssl.cnf -key $user.key -out $user.csr
	openssl x509 -req -in $user.csr -CA /etc/ssl/certs/$DOMAIN.ca.crl.pem -CAkey /etc/ssl/private/$DOMAIN.ca.key -CAcreateserial -out $user.pem -days 1024 -sha256
	cat $user.pem $user.key /etc/ssl/certs/$DOMAIN.ca.crl.pem > $user.clientcert.pem

	echo -en "\n"
	${LOGGING} -i "IMPORTANT - certificate and key for the user \"$user\" are saved to his home. He can download it later over a secure SSH connection - IMPORTANT"
	echo -en "\n"

	${LOGGING} -i "Cleaning up.."
    mv $user.clientcert.pem /home/$user/$user.$DOMAIN.clientcert.pem
    chmod 600 /home/$user/$user.$DOMAIN.clientcert.pem
    chown $user.$user /home/$user/$user.$DOMAIN.clientcert.pem
	rm $user.pem $user.key
    rm openssl.cnf alice.csr

    ${LOGGING} -i "Creating zip file for $user user artifacts"
    zip -jm /home/$user/${user}_artifacts.zip /home/$user/passwords.txt /home/$user/id_rsa /home/$user/id_rsa.pub /home/$user/$user.$DOMAIN.clientcert.pem
    chown $user.$user /home/$user/${user}_artifacts.zip

    echo "user: $user, command: rsync -e \"ssh -i PATH_TO_YOUR_SSH_PRIVATE_KEY\" --remove-source-files -av $user@$DOMAIN:/home/$user/${user}_artifacts.zip ./" >> download_commands.txt
done
unset ca_password
