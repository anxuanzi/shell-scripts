#!/bin/bash

# Set the timezone to Chicago
timedatectl set-timezone America/Chicago

# Enable and start the NTP-based synchronization
systemctl enable --now chronyd
