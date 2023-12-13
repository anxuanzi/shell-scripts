#!/bin/bash

docker volume create portainer_data

docker run -d \
  --name portainer \
  --restart always \
  -p 9443:9443 \
  -p 8000:8000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  --label com.centurylinklabs.watchtower.enable=true \
  portainer/portainer-ce:latest
