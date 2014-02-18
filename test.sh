#!/bin/bash

NAME="${USER}/drupaltestbot"

# if image ${USER}/drupal does not exist run:
IMAGE=$(sudo docker images | grep "${NAME}")

if [ "$IMAGE" == "" ]; then 
  echo "Docker image ${NAME} needs to be created..."; 
  sudo docker build -t ${NAME} . ;
  else
  echo "Docker image ${NAME} found!"; 
fi

CONTAINER=$(sudo docker run -i -d ${NAME} | tail -n1)
echo "Container: ${CONTAINER} started"
sleep 30
sudo docker logs ${CONTAINER}

