#!/bin/bash

echo "creating portainer container..."

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

# File path
DOCKER_CONFIG_FILE="/root/.docker/config.json"

# Check if the file does not exist
if [ ! -f "$DOCKER_CONFIG_FILE" ]; then
    # Create the directory if it doesn't exist
    mkdir -p /root/.docker

    # Create the file
    touch "$DOCKER_CONFIG_FILE"
    echo "Docker Configuration File created: $DOCKER_CONFIG_FILE"
else
    echo "File already exists: $DOCKER_CONFIG_FILE"
fi

echo "setting up watchertower container..."

docker run -d \
  --name watchtower \
  --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /root/.docker/config.json:/config.json \
  -e WATCHTOWER_CLEANUP=true \
  -e WATCHTOWER_INCLUDE_STOPPED=true \
  -e WATCHTOWER_REVIVE_STOPPED=true \
  -e WATCHTOWER_POLL_INTERVAL=5 \
  -e WATCHTOWER_LABEL_ENABLE=true \
  containrrr/watchtower:latest
