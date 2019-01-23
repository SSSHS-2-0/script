#!/bin/bash

#========================================================
# Filename: sshkeys.sh
#
# Description: Generate SSH keys for users
#========================================================

for user in $SSHUSERS; do
    ${LOGGING} -i "Generating SSH key for user $user"
    ${LOGGING} -i "IMPORTANT - make sure you remember ALL the passphrases and save your keys to some secure location - IMPORTANT"
    echo -en "\n"

    mkdir -p /home/$user/.ssh
    touch /home/$user/.ssh/authorized_keys
    while true; do
        read -sp "Enter passphrase (at least 5 characters): " password
        echo -en "\n"
        read -sp "Enter same passphrase again: " password_verify
        echo -en "\n"
		if [ "${#password}" -lt 5 ]; then
			echo -e "Sorry, passphrase too short\nTry again"
		else
        	if [ "$password" == "$password_verify" ]; then
        	    break
        	else
        	    echo -e "Sorry, passwords do not match\nTry again"
        	fi
		fi
    done
    ssh-keygen -b 4096 -C "$user@$DOMAIN" -E sha256 -N ${password} -t rsa -f /home/$user/.ssh/id_rsa
	echo "SSH-Key passphrase: $password" >> /home/$user/passwords.txt
    unset password
    cat /home/$user/.ssh/id_rsa.pub > /home/$user/.ssh/authorized_keys

    ${LOGGING} -i "IMPORTANT - This is your private key, this is the only thing you need right to save. All of your certificate and keys are saved to your home. You need this key to download them. - IMPORTANT"
    cat /home/$user/.ssh/id_rsa

    ${LOGGING} -i "Cleaning up.."
    mv /home/$user/.ssh/id_rsa /home/$user/id_rsa
    mv /home/$user/.ssh/id_rsa.pub /home/$user/id_rsa.pub
    chmod 600 /home/$user/id_rsa /home/$user/id_rsa.pub
    chown $user.$user /home/$user/id_rsa /home/$user/id_rsa.pub
    chown -R $user:$user /home/$user/
    chmod 700 /home/$user/.ssh
    chmod 644 /home/$user/.ssh/authorized_keys
done
