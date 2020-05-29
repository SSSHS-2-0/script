#!/bin/bash

#========================================================
# Filename: server_config.sh
#
# Description: 
#   Configurations for SSH
#
# Source: from SSSHS 1.0
#
#========================================================



sed -i 's/^X11Forwarding.*/X11Forwarding no/g' /etc/ssh/sshd_config
sed -i 's/^UseDNS.*/UseDNS yes/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config

if grep -Pq "^HostKeyAlgorithms .*" /etc/ssh/sshd_config; then
  sed -i 's/^HostKeyAlgorithms.*/HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp521,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256/g' /etc/ssh/sshd_config
else
  cat << EOF >> /etc/ssh/sshd_config
HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp521,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256
EOF
fi

if grep -Pq "^KexAlgorithms .*" /etc/ssh/sshd_config; then
  sed -i 's/^KexAlgorithms.*/KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256/g' /etc/ssh/sshd_config
else
  cat << EOF >> /etc/ssh/sshd_config
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256
EOF
fi

if grep -Pq "^MACs .*" /etc/ssh/sshd_config; then
  sed -i 's/^MACs.*/MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com/g' /etc/ssh/sshd_config
else
  cat << EOF >> /etc/ssh/sshd_config
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
EOF
fi

if grep -Pq "^Ciphers .*" /etc/ssh/sshd_config; then
  sed -i 's/^Ciphers.*/Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr/g' /etc/ssh/sshd_config
else
  cat << EOF >> /etc/ssh/sshd_config
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
EOF
fi
