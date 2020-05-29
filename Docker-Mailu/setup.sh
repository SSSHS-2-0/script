#!/bin/bash

#========================================================
# Filename: setup.sh
#
# Description: 
#   Prepares the Mailu container
#
#========================================================
domain=$(cat "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/domain)

cat << EOF > /srv/docker-reverseproxy/conf.d/docker-webmail-upstream.conf
upstream webmail {
    server front:80;
    
    keepalive 32;
    }

upstream wadmin {
  server admin:80;

  keepalive 32;
}
EOF
   
    cat << EOF > /srv/docker-reverseproxy/conf.d/docker-webmail-$domain-location.conf
location /webmail {
            proxy_pass http://webmail;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /ui {
            proxy_pass http://wadmin;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
EOF
#add the necessary lines to the docker-compose files

cat << EOF >> $SCRIPT_SOURCE_DIR/docker-compose.yml

  # Mailu
  # External dependencies
  redis:
    container_name: redis
    image: redis:alpine
    restart: always
    volumes:
      - "/srv/docker-mailu/data:/data"
  
  # Core services
  front:
    container_name: front
    image: \${DOCKER_ORG:-mailu}/\${DOCKER_PREFIX:-}nginx:\${MAILU_VERSION:-1.7}
    restart: always
    env_file: mailu.env
    logging:
      driver: json-file
    expose:
      - "80"
    ports:
      - "25:25"
      - "465:465"
      - "587:587"
      - "110:110"
      - "995:995"
      - "143:143"
      - "993:993"
    volumes:
      - "/srv/docker-mailu/certs:/certs"
      - "/srv/docker-mailu/overrides:/overrides"

  admin:
    container_name: admin
    image: \${DOCKER_ORG:-mailu}/\${DOCKER_PREFIX:-}admin:\${MAILU_VERSION:-1.7}
    restart: always
    env_file: mailu.env
    expose:
      - "80"
    volumes:
      - "/srv/docker-mailu/data:/data"
      - "/srv/docker-mailu/dkim:/dkim"
    depends_on:
      - redis

  imap:
    container_name: imap
    image: \${DOCKER_ORG:-mailu}/\${DOCKER_PREFIX:-}dovecot:\${MAILU_VERSION:-1.7}
    restart: always
    env_file: mailu.env
    volumes:
      - "/srv/docker-mailu/mail:/mail"
      - "/srv/docker-mailu/overrides:/overrides"
    depends_on:
      - front

  smtp:
    container_name: smtp
    image: \${DOCKER_ORG:-mailu}/\${DOCKER_PREFIX:-}postfix:\${MAILU_VERSION:-1.7}
    restart: always
    env_file: mailu.env
    volumes:
      - "/srv/docker-mailu/overrides:/overrides"
    depends_on:
      - front

  antispam:
    container_name: antispam
    image: \${DOCKER_ORG:-mailu}/\${DOCKER_PREFIX:-}rspamd:\${MAILU_VERSION:-1.7}
    restart: always
    env_file: mailu.env
    volumes:
      - "/srv/docker-mailu/filter:/var/lib/rspamd"
      - "/srv/docker-mailu/dkim:/dkim"
      - "/srv/docker-mailu/overrides/rspamd:/etc/rspamd/override.d"
    depends_on:
      - front

  # Optional services
  fetchmail:
    container_name: fetchmail
    image: \${DOCKER_ORG:-mailu}/\${DOCKER_PREFIX:-}fetchmail:\${MAILU_VERSION:-1.7}
    restart: always
    env_file: mailu.env

  # Webmail
  webmail:
    container_name: webmail
    image: \${DOCKER_ORG:-mailu}/\${DOCKER_PREFIX:-}roundcube:\${MAILU_VERSION:-1.7}
    restart: always
    env_file: mailu.env
    volumes:
      - "/srv/docker-mailu/webmail"
    depends_on:
      - imap
EOF