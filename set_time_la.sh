#!/bin/bash

# Set the timezone to Los Angeles
timedatectl set-timezone America/Los_Angeles

# Enable and start the NTP-based synchronization
systemctl enable --now chronyd
