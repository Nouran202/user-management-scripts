#!/bin/bash 

# Author: Nouran Alaa Mohamed
# Date: 2025-05-09
# Version: 1.0.0
#
# Purpose: This script is designed to automate the process of creating a new user on Unix-like operating systems (Linux).
#          It allows the user to:
#          - Create a new user with a specified or default password.
#          - Set up SSH key-based authentication if an SSH key is provided.
#          - Add the user to the appropriate administrative group (`sudo` for Debian/Ubuntu or `wheel` for RHEL/CentOS/Fedora).
#          - Force the user to change their password upon first login.
#          - Ensure the script is executed with root privileges to perform administrative actions.
#
# Notes:
# - This script is ideal for system administrators or security engineers who need to quickly provision users 
#   with appropriate privileges and secure SSH login setups.
# - The script detects the operating system and applies the correct admin group membership based on the system type.
# - The password is automatically set to expire on the user's first login to enforce a password change immediately.
# - The script handles user creation, password assignment, and SSH key setup, making it a comprehensive user setup solution.
#
# Requirements:
# - Root (administrator) privileges
# - A valid SSH key file (if desired) for SSH key-based authentication
#
# Usage:
#   bash add_user_with_ssh.sh <username> [password] [ssh_key_file]
#
# Example:
#   bash add_user_with_ssh.sh johnpassword123 john_ssh_key.pub
#   This will create the user 'john' with the password 'password123' and set up SSH key-based authentication.

if [ "$EUID" -ne 0 ]; then
    echo "PLEASE RUN AS ROOT"
    exit
fi

if [ $# -lt 1 ]; then
    echo "Usage: $0 username [password]"
    exit 1
fi

USERNAME="$1"
PASSWORD="${2:-"DefaultPassword123"}"
chage -d 0 "$USERNAME"  # Force password change on first login

if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists"
    exit 1
fi

# Create the user and set the password
useradd -m "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd

# Detect system type and add to the correct admin group (sudo or wheel)
if grep -iqE '^ID="?ubuntu"?|^ID="?debian"?' /etc/os-release; then
    usermod -aG sudo "$USERNAME"
    echo "Added $USERNAME to 'sudo' group (Debian/Ubuntu)."
elif grep -iqE '^ID="?fedora"?|^ID="?centos"?|^ID="?rhel"?' /etc/os-release; then
    usermod -aG wheel "$USERNAME"
    echo "Added $USERNAME to 'wheel' group (RHEL/CentOS/Fedora)."
else
    echo "OS not detected. Please add $USERNAME to the admin group manually."
fi

echo "User $USERNAME created with full privileges."

# Check if an SSH key file is provided as an environment variable or argument
SSH_KEY_FILE="${3:-""}"

# If an SSH key file is provided and exists, proceed to add it
if [ -n "$SSH_KEY_FILE" ] && [ -f "$SSH_KEY_FILE" ]; then
    # Create the .ssh directory in the user's home directory
    mkdir -p /home/"$USERNAME"/.ssh
    
    # Copy the provided SSH public key to the authorized_keys file
    cat "$SSH_KEY_FILE" > /home/"$USERNAME"/.ssh/authorized_keys
    
    # Set proper permissions on the .ssh directory and the authorized_keys file
    chmod 700 /home/"$USERNAME"/.ssh               # Only the user can access the .ssh folder
    chmod 600 /home/"$USERNAME"/.ssh/authorized_keys  # Only the user can access the authorized_keys file
    
    # Change ownership of the .ssh directory and its contents to the new user
    chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh
    
    # Inform the user that the SSH key has been added
    echo "SSH key added for $USERNAME."
else
    # Inform the user if no SSH key file is provided
    echo "No SSH key provided or file does not exist. User will authenticate with password."
fi
