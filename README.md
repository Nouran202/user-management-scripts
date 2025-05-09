# User Management Scripts

This repository contains Bash scripts for managing users on Unix-like systems.

## Scripts

### 1. **add_user_admin.sh**

Creates a new user with `sudo` privileges, and optionally adds an SSH key for passwordless login.

#### Usage:
bash add_user_admin.sh <username> [password] [ssh_key_file]
<username>: The new user’s name.

[password]: (Optional) User password (default: DefaultPassword123).

[ssh_key_file]: (Optional) Path to an SSH public key file.

Example:
bash add_user_admin.sh john mypassword /path/to/ssh_key.pub

2. delete_sudo_user.sh
Deletes a user with sudo privileges from the system.

Usage:
bash delete_sudo_user.sh <username>
<username>: The name of the user to delete.

Example:
bash delete_sudo_user.sh john
Prerequisites
Must be run as root.

Designed for Linux-based systems (Ubuntu, Debian, RHEL, CentOS, Fedora).
