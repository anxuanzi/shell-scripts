# FTA System Utility Scripts

This repository contains a collection of shell scripts designed to assist with common system administration tasks on CentOS 9 Stream and compatible systems. An entry point script, `setup.sh`, is provided for easy downloading and execution of these utilities.

## Features

*   **OS Initialization**: Comprehensive server setup including SELinux configuration, software installation (common tools, Node.js, Yarn, modern CLI alternatives), SSH hardening, system limits, and kernel parameter tuning (`fta_os_init.sh`).
*   **Docker Installation**: Installs Docker CE, Docker Compose, and related tools (`install_docker.sh`).
*   **Portainer & Watchtower**: Deploys Portainer (Docker management UI) and Watchtower (automatic container updates) (`install_portainer.sh`).
*   **Timezone Configuration**: Scripts to set the system timezone to specific regions (e.g., America/Chicago, America/Los_Angeles) and ensure `chronyd` is active (`set_time_chicago.sh`, `set_time_la.sh`).
*   **User-Friendly Interface**: A `setup.sh` script to download all necessary utilities and provide a menu-driven interface for their execution.
*   **Enhanced Output**: Scripts use colored output for better readability and provide clear feedback on operations.
*   **Idempotency**: Scripts are designed to be safe to re-run, checking for existing configurations where possible.
*   **Common Utilities**: A `utils.sh` script provides shared functions for messaging and error handling to all other scripts.

## Prerequisites

*   A CentOS 9 Stream based system (or a compatible RHEL derivative).
*   Internet access for downloading scripts and packages.
*   `curl` or `wget` installed on your system (for the `setup.sh` script to download other files).
*   Root or sudo privileges are required to run these scripts, as they perform system-level configurations.

## Getting Started: Using `setup.sh`

The `setup.sh` script is the recommended way to get started. It will download all the other scripts and provide you with an interactive menu.

1.  **Download `setup.sh`**:
    You can download `setup.sh` using either `curl` or `wget`.

    Using `curl`:
    ```bash
    curl -sSLfO https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO_NAME/main/setup.sh
    ```

    Using `wget`:
    ```bash
    wget -qO setup.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO_NAME/main/setup.sh
    ```
    **Note**: Replace `YOUR_USERNAME`, `YOUR_REPO_NAME`, and `main` with the appropriate values if you are using a fork or a different branch. The `setup.sh` script itself contains these variables at the top; you might need to edit them there as well if you download it and move it elsewhere or if the script cannot determine its origin.

2.  **Make `setup.sh` Executable**:
    ```bash
    chmod +x setup.sh
    ```

3.  **Run `setup.sh`**:
    ```bash
    ./setup.sh
    ```
    The script will first attempt to download all the necessary utility scripts (like `fta_os_init.sh`, `utils.sh`, etc.) into the current directory.
    Once the downloads are complete, you will be presented with a menu to choose which operation you want to perform.

    **Menu Options typically include**:
    *   Initialize OS
    *   Install Docker
    *   Install Portainer & Watchtower
    *   Set Timezone to Chicago
    *   Set Timezone to Los Angeles
    *   Re-download/Update all scripts
    *   Exit

## Script Details

### `setup.sh`
*   **Purpose**: Entry point to download all other scripts and provide a selection menu.
*   **Usage**: Download, make executable, and run as shown above.

### `utils.sh`
*   **Purpose**: Contains common utility functions (colored messaging, error checking) sourced by other scripts. Not meant to be run directly.

### `fta_os_init.sh`
*   **Purpose**: Performs initial server setup. This is a comprehensive script. Review its actions if you are particular about specific configurations.
*   **Key Actions**: Disables SELinux (sets to permissive then configures to disabled), installs EPEL, essential packages, Node.js, Yarn, various modern CLI tools (like `rg`, `btm`, `glances`, `dust`, `procs`, `curlie`, `duf`, `fd`), configures aliases for them, hardens SSH, adjusts system limits, and tunes kernel parameters. Performs a system update at the end.
*   **Note**: Requires a reboot for some changes (like SELinux in config and some kernel parameters) to take full effect.

### `install_docker.sh`
*   **Purpose**: Installs Docker Community Edition and Docker Compose.
*   **Key Actions**: Removes old Docker versions, sets up the official Docker repository, installs Docker packages, starts and enables the Docker service. Verifies installation with `hello-world`.

### `install_portainer.sh`
*   **Purpose**: Installs Portainer (a web UI for Docker) and Watchtower (for automatic Docker container updates).
*   **Prerequisites**: Docker must be installed and running.
*   **Key Actions**: Creates a data volume for Portainer, runs Portainer and Watchtower containers. Configures Watchtower to only update labeled containers.

### `set_time_chicago.sh` / `set_time_la.sh`
*   **Purpose**: Sets the system timezone (to America/Chicago or America/Los_Angeles respectively) and enables/starts `chronyd` for time synchronization.

## Important Notes

*   **Run as Root/Sudo**: These scripts perform system-level changes and require root privileges. Run them using `sudo ./script_name.sh` or by logging in as root. The `setup.sh` should also be run with sufficient privileges if the scripts it calls require them.
*   **Review Scripts**: It's always a good practice to review scripts downloaded from the internet before executing them, especially when running as root.
*   **Customization**: If you need to customize the behavior (e.g., packages installed by `fta_os_init.sh`), you can modify the scripts after they are downloaded by `setup.sh`.
*   **`setup.sh` Configuration**: The `setup.sh` script has `GITHUB_USER`, `GITHUB_REPO`, and `BRANCH` variables at the top. If you are using a fork or a different branch, ensure these are updated in your copy of `setup.sh` or in the script itself if you intend to distribute it.

## Contributing

Feel free to fork this repository, make improvements, and submit pull requests.
