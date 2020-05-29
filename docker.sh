#!/bin/bash
#========================================================
# Filename: docker.sh
#
# Description:
#	  Main script for installing and removing Docker modules.
#
#========================================================

#stop and delete all existing containers
echo "stopping containers..."
docker stop $(docker ps -a -q) &>/dev/null
echo "done"
echo "removing containers..."
docker rm $(docker ps -a -q) &>/dev/null
echo "done"
# create the docker-compose file
echo "Creating docker compose file..."
echo "version: '3.3'" > $SCRIPT_SOURCE_DIR/docker-compose.yml
echo "services:" >> $SCRIPT_SOURCE_DIR/docker-compose.yml

#add the images to the yml file
declare -g postcompose=()

docker_count=0
for D in Docker-*; do
  if [ -d "${D}" ]; then
    FILE="${D}/installed"
    if test -f "$FILE"; then
      ((docker_count++))
      declare -g _dock_$docker_count=$D
      FILE="${D}/post_compose.sh"
      if test -f "$FILE"; then
      postcompose+=($D)
      fi
    fi
  fi
done

for (( c=1; c<=$docker_count; c++ ))
do
    FILEVAR="_dock_$c"
    (exec "${!FILEVAR}/setup.sh")
done

cat << EOF >> $SCRIPT_SOURCE_DIR/docker-compose.yml
    
# Custom network so all services can communicate using a FQDN
networks:
    meet.jitsi:

EOF

echo "done"

if ((docker_count > 0))
then
  echo "starting containers..."
  docker-compose up -d
  echo "done"
  
  echo "executing post compose scripts..."
  for item in ${postcompose[*]}
  do 
    cd $item
    ./post_compose.sh
    cd ..
  done
  echo "done"
fi
