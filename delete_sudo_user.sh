#!/bin/bash

# Author: Nouran Alaa Mohamed
# Date: 2025-05-09
# Version: 1.0.0
#
# Purpose: This script is designed to delete a user who has sudo (administrative) privileges on a Unix-like operating system.
#          It ensures that the user exists, removes the user from the sudo or wheel group (depending on the system),
#          and deletes the user along with their home directory.
#
# Notes:
# - The script will prompt for confirmation before deleting the user to avoid accidental removal.
# - This script is ideal for system administrators who need to manage user accounts securely and efficiently.
# - The script checks for root privileges before making any changes, as user deletion requires administrative access.
#
# Requirements:
# - Root (administrator) privileges
#
# Usage:
#   bash delete_sudo_user.sh <username>
#
# Example:
#   bash delete_sudo_user.sh john
#   This will remove the user 'john' from the system, including their home directory and sudo privileges.

if [ "$EUID" -ne 0 ]; then
    echo "PLEASE RUN AS ROOT"
    exit 1
fi

if [ $# -lt 1 ]; then
    echo "Usage: $0 username"
    exit 1
fi

USERNAME="$1"

# Check if the user exists
if ! id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME does not exist"
    exit 1
fi

# Remove the user from the sudo or wheel group (depending on the system)
if grep -iqE '^ID="?ubuntu"?|^ID="?debian"?' /etc/os-release; then
    deluser "$USERNAME" sudo
    echo "Removed $USERNAME from 'sudo' group (Debian/Ubuntu)."
elif grep -iqE '^ID="?fedora"?|^ID="?centos"?|^ID="?rhel"?' /etc/os-release; then
    deluser "$USERNAME" wheel
    echo "Removed $USERNAME from 'wheel' group (RHEL/CentOS/Fedora)."
else
    echo "OS not detected. Please manually remove $USERNAME from the admin group."
fi

# Confirm deletion and prompt the user
read -p "Are you sure you want to delete the user $USERNAME and their home directory? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "User deletion canceled."
    exit 0
fi

# Delete the user and their home directory
userdel -r "$USERNAME"
if [ $? -eq 0 ]; then
    echo "User $USERNAME and their home directory have been deleted."
else
    echo "An error occurred while deleting the user $USERNAME."
    exit 1
fi
