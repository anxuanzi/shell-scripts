#!/bin/bash

# ==============================================================================
# Script Name: utils.sh
# Description: This script provides common utility functions for other shell
#              scripts, including colored messaging and error handling.
# Author:      Your Name/Org (Adapted from common utilities)
# Version:     1.0
# Date:        YYYY-MM-DD
# Notes:       This script is intended to be sourced by other scripts.
#              Example: source "$(dirname "$0")/utils.sh"
# ==============================================================================

# --- Color Definitions ---
# Define ANSI escape codes for colored output.
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m' # No Color (alias for NC if preferred)

# --- Output Functions ---
# These functions print messages with corresponding colors.

# msg_info: Prints a message in BLUE.
# Usage: msg_info "This is an informational message."
msg_info() {
    echo -e "${BLUE}[INFO] $1${RESET}"
}

# msg_success: Prints a message in GREEN.
# Usage: msg_success "Operation completed successfully."
msg_success() {
    echo -e "${GREEN}[SUCCESS] $1${RESET}"
}

# msg_warning: Prints a message in YELLOW.
# Usage: msg_warning "This is a warning message."
msg_warning() {
    echo -e "${YELLOW}[WARNING] $1${RESET}"
}

# msg_error: Prints a message in RED.
# Usage: msg_error "An error occurred."
msg_error() {
    echo -e "${RED}[ERROR] $1${RESET}"
}

# --- Error Handling Function ---

# check_exit_status: Checks the exit status of the previously executed command.
# If the command failed (exit status non-zero), it prints the failure_prefix_message
# using msg_error and then exits the script with the same status.
# If the command succeeded (exit status zero), it prints the success_message
# using msg_success.
#
# Usage:
#   some_command
#   check_exit_status "Failure message prefix for some_command" "Success message for some_command."
#
# Example:
#   mkdir /tmp/my_dir
#   check_exit_status "Failed to create directory /tmp/my_dir" "Directory /tmp/my_dir created."
#
check_exit_status() {
    local last_exit_status=$? # Capture the exit status of the previous command.
    # $1: Message to display if the command failed (failure message).
    # $2: Message to display if the command succeeded (success message).

    if [ "${last_exit_status}" -ne 0 ]; then
        msg_error "$1 (Exit Status: ${last_exit_status})" # $1 is the failure message
        exit "${last_exit_status}"
    else
        msg_success "$2" # $2 is the success message
    fi
}

# --- Make script executable (though it's meant to be sourced) ---
# This is more of a convention for scripts in a bin directory.
# Sourcing does not require the script to be executable.
# chmod +x "$(dirname "$0")/$(basename "$0")"
# For this tool environment, direct chmod might not be needed or work as expected.
# The primary use is sourcing.

msg_info "Utility functions (utils.sh) loaded."
# This message will appear whenever a script sources utils.sh,
# which can be helpful for debugging. Can be commented out if too verbose.
