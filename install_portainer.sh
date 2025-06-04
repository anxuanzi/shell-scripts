#!/bin/bash

# ==============================================================================
# Script Name: install_portainer.sh
# Description: This script installs Portainer (a Docker management UI) and
#              Watchtower (an automatic Docker container updater).
# Author:      Your Name/Org
# Version:     1.0
# Date:        YYYY-MM-DD
# Prerequisites: Docker must be installed and running.
# ==============================================================================

# Source utility functions
UTILS_PATH="$(dirname "$0")/utils.sh"
if [ ! -f "${UTILS_PATH}" ]; then
    echo -e "\033[0;31m[ERROR] utils.sh not found at ${UTILS_PATH}. Please ensure it's in the same directory as this script.\033[0m"
    exit 1
fi
source "${UTILS_PATH}"

# --- Script Start ---
# The msg_info from utils.sh will confirm it's loaded.
msg_info "Starting Portainer and Watchtower installation script..."

# --- Prerequisite Check: Docker ---
msg_info "Checking for Docker installation..."
if ! command -v docker &> /dev/null; then
    msg_error "Docker command not found. Please install Docker before running this script."
    exit 1
fi
docker --version
msg_success "Docker is installed."

# --- Portainer Installation ---
PORTAINER_VOLUME_NAME="portainer_data"
PORTAINER_CONTAINER_NAME="portainer"

# 1. Create Portainer Data Volume (Idempotent)
msg_info "Checking for Portainer data volume ('${PORTAINER_VOLUME_NAME}')..."
if docker volume inspect "${PORTAINER_VOLUME_NAME}" &> /dev/null; then
    msg_warning "Docker volume '${PORTAINER_VOLUME_NAME}' already exists. Skipping creation."
else
    msg_info "Creating Portainer data volume ('${PORTAINER_VOLUME_NAME}')..."
    docker volume create "${PORTAINER_VOLUME_NAME}"
    check_exit_status "Failed to create Docker volume '${PORTAINER_VOLUME_NAME}'." "Docker volume '${PORTAINER_VOLUME_NAME}' created successfully."
fi

# 2. Run Portainer Container (Idempotent)
msg_info "Checking for existing Portainer container ('${PORTAINER_CONTAINER_NAME}')..."
if docker ps -a --filter "name=^/${PORTAINER_CONTAINER_NAME}$" --format "{{.Names}}" | grep -q "^${PORTAINER_CONTAINER_NAME}$"; then
    msg_warning "Portainer container ('${PORTAINER_CONTAINER_NAME}') already exists."
    # Optional: Add logic here to ask user if they want to stop and remove, then recreate.
    # For now, we just skip.
    msg_info "To reinstall Portainer, please stop and remove the existing container manually using:"
    msg_info "  docker stop ${PORTAINER_CONTAINER_NAME} && docker rm ${PORTAINER_CONTAINER_NAME}"
else
    msg_info "Starting Portainer CE container ('${PORTAINER_CONTAINER_NAME}')..."
    # Command Explanation:
    # -d: Run container in detached mode (in the background).
    # --name ${PORTAINER_CONTAINER_NAME}: Assign a specific name to the container.
    # --restart always: Automatically restart the container if it stops (e.g., on server reboot).
    # -p 9443:9443: Map port 9443 on the host to port 9443 in the container (for Portainer UI over HTTPS).
    # -p 8000:8000: Map port 8000 on the host to port 8000 in the container (for Portainer Edge Agent, optional).
    # -v /var/run/docker.sock:/var/run/docker.sock: Mount the Docker socket to allow Portainer to manage Docker.
    # -v ${PORTAINER_VOLUME_NAME}:/data: Mount the 'portainer_data' volume to persist Portainer's configuration.
    # --label com.centurylinklabs.watchtower.enable=true: Label for Watchtower to know it should update this container.
    # portainer/portainer-ce:latest: Use the latest stable community edition of Portainer.
    docker run -d \
      --name "${PORTAINER_CONTAINER_NAME}" \
      --restart always \
      -p 9443:9443 \
      -p 8000:8000 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "${PORTAINER_VOLUME_NAME}":/data \
      --label com.centurylinklabs.watchtower.enable=true \
      portainer/portainer-ce:latest
    check_exit_status "Failed to start Portainer container." "Portainer container started successfully."

    SERVER_IP=$(hostname -I | awk '{print $1}')
    msg_success "Portainer UI should be accessible at: https://${SERVER_IP}:9443"
    msg_info "During first setup, you will be asked to create an admin user and password."
fi

# --- Docker Configuration for Watchtower ---
# This step ensures Watchtower can authenticate with private registries if needed.
# For public images, this might not be strictly necessary but is good practice.
DOCKER_CONFIG_DIR="/root/.docker" # Watchtower typically runs as root if accessing /var/run/docker.sock
DOCKER_CONFIG_FILE="${DOCKER_CONFIG_DIR}/config.json"

msg_info "Checking Docker configuration file for Watchtower ('${DOCKER_CONFIG_FILE}')..."
if [ ! -f "$DOCKER_CONFIG_FILE" ]; then
    msg_info "Docker config file '${DOCKER_CONFIG_FILE}' not found. Creating it..."
    mkdir -p "${DOCKER_CONFIG_DIR}"
    check_exit_status "Failed to create directory '${DOCKER_CONFIG_DIR}'." "Directory '${DOCKER_CONFIG_DIR}' created or already exists."
    echo "{}" > "${DOCKER_CONFIG_FILE}" # Create an empty JSON file
    check_exit_status "Failed to create Docker config file '${DOCKER_CONFIG_FILE}'." "Docker config file '${DOCKER_CONFIG_FILE}' created."
    msg_warning "Created an empty Docker config file. If Watchtower needs to pull from private registries, configure Docker login credentials first."
else
    msg_success "Docker configuration file ('${DOCKER_CONFIG_FILE}') already exists."
fi

# --- Watchtower Installation ---
WATCHTOWER_CONTAINER_NAME="watchtower"

# Run Watchtower Container (Idempotent)
msg_info "Checking for existing Watchtower container ('${WATCHTOWER_CONTAINER_NAME}')..."
if docker ps -a --filter "name=^/${WATCHTOWER_CONTAINER_NAME}$" --format "{{.Names}}" | grep -q "^${WATCHTOWER_CONTAINER_NAME}$"; then
    msg_warning "Watchtower container ('${WATCHTOWER_CONTAINER_NAME}') already exists."
    msg_info "To reinstall Watchtower, please stop and remove the existing container manually using:"
    msg_info "  docker stop ${WATCHTOWER_CONTAINER_NAME} && docker rm ${WATCHTOWER_CONTAINER_NAME}"
else
    msg_info "Starting Watchtower container ('${WATCHTOWER_CONTAINER_NAME}')..."
    # Command Explanation:
    # -d: Run container in detached mode.
    # --name ${WATCHTOWER_CONTAINER_NAME}: Assign a specific name to the container.
    # --restart always: Automatically restart the container if it stops.
    # -v /var/run/docker.sock:/var/run/docker.sock: Mount the Docker socket to allow Watchtower to manage other containers.
    # -v ${DOCKER_CONFIG_FILE}:/config.json: Mount the Docker config file for potential private registry access.
    # -e WATCHTOWER_CLEANUP=true: Remove old images after updating to a new version.
    # -e WATCHTOWER_INCLUDE_STOPPED=true: Check for updates for stopped containers as well (they will be updated and restarted).
    # -e WATCHTOWER_REVIVE_STOPPED=true:  Restart containers that were stopped when an update is found.
    # -e WATCHTOWER_POLL_INTERVAL=300: Check for updates every 300 seconds (5 minutes). Default is 86400 (24 hours).
    # -e WATCHTOWER_LABEL_ENABLE=true: Only update containers that have the 'com.centurylinklabs.watchtower.enable=true' label (like Portainer above).
    # containrrr/watchtower:latest: Use the latest stable version of Watchtower.
    docker run -d \
      --name "${WATCHTOWER_CONTAINER_NAME}" \
      --restart always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "${DOCKER_CONFIG_FILE}":"/config.json" \
      -e WATCHTOWER_CLEANUP=true \
      -e WATCHTOWER_INCLUDE_STOPPED=true \
      -e WATCHTOWER_REVIVE_STOPPED=true \
      -e WATCHTOWER_POLL_INTERVAL=300 \
      -e WATCHTOWER_LABEL_ENABLE=true \
      containrrr/watchtower:latest
    check_exit_status "Failed to start Watchtower container." "Watchtower container started successfully."
    msg_info "Watchtower will now monitor labeled containers and update them automatically."
fi

msg_success "===== Portainer and Watchtower Installation/Setup Checked! ====="
if ! docker ps -a --filter "name=^/${PORTAINER_CONTAINER_NAME}$" --format "{{.Names}}" | grep -q "^${PORTAINER_CONTAINER_NAME}$"; then
     msg_warning "Portainer was not started by this script run (likely skipped as it already existed)."
else
    msg_info "Portainer UI: https://$(hostname -I | awk '{print $1}'):9443"
fi
if ! docker ps -a --filter "name=^/${WATCHTOWER_CONTAINER_NAME}$" --format "{{.Names}}" | grep -q "^${WATCHTOWER_CONTAINER_NAME}$"; then
    msg_warning "Watchtower was not started by this script run (likely skipped as it already existed)."
fi

exit 0
