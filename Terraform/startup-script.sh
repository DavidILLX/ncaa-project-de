#!/bin/bash
set -e

# Ensure the package list is up-to-date and perform an upgrade
<<<<<<< HEAD
apt-get update -y
apt-get upgrade -y

# Install dependencies
apt-get install -y wget curl lsb-release

# Install Docker
apt-get install -y docker.io
apt-get install -y docker-buildx-plugin

# Install Docker Compose to /usr/local/bin
mkdir -p bin
cd bin
wget -q https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64 -O /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
cd ..
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc

# Install Anaconda
wget -q https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh
bash Anaconda3-2024.10-1-Linux-x86_64.sh -b -p /opt/anaconda3
rm -f Anaconda3-2024.10-1-Linux-x86_64.sh

# Add Anaconda to PATH (system-wide)
echo 'export PATH="/opt/anaconda3/bin:$PATH"' | sudo tee /etc/profile.d/anaconda3.sh
chmod +x /etc/profile.d/anaconda3.sh
=======
sudo apt-get update -y
sudo apt-get upgrade -y

# Install dependencies with sudo
sudo apt-get install -y wget curl lsb-release sudo

# Install Docker
sudo apt-get install -y docker.io

# Install Docker Compose
sudo mkdir -p bin
cd bin
sudo wget https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64 -O docker-compose
sudo chmod +x docker-compose
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
cd ..

# Install Anaconda
sudo wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh
sudo bash ~/Anaconda3-2024.10-1-Linux-x86_64.sh -b -p $HOME/anaconda3
source ~/anaconda3/bin/activate
conda init --all
rm -f Anaconda3-2024.10-1-Linux-x86_64.sh 

# Ensure the changes take effect
source ~/.bashrc
>>>>>>> 2ad4264 (Initial commit with .gitignore)
