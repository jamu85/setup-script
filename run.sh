#! /usr/bin/env bash

set -euo pipefail

# Source .env
printf "Source environment variables..\n"
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

# Update hostname
printf "Setting hostname...\n"
printf "$SERVER_HOSTNAME\n" > /etc/hostname
hostname -F /etc/hostname

# Update hosts file
printf "Updating hosts...\n"
printf "$SERVER_IP $SERVER_HOSTNAME $SERVER_HOSTNAME\n" >> /etc/hosts
hostname -f

# Set timezone
printf "Setting UTC timezone...\n"
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Create user account.
useradd -m -s /bin/bash -G sudo $USER_LOGIN
usermod -p $(printf $USER_PASS | openssl passwd -1 -stdin) $USER_LOGIN

# Initialize SSH authorized keys for user account.
mkdir /home/$USER_LOGIN/.ssh
touch /home/$USER_LOGIN/.ssh/authorized_keys
chmod -R 700 /home/$USER_LOGIN/.ssh
chmod 644 /home/$USER_LOGIN/.ssh/authorized_keys

# Initialization
apt update
apt upgrade

# Install essentials
apt install git build-essential docker.io -y
usermod -aG docker $USER_LOGIN

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose`
chmod +x /usr/local/bin/docker-compose