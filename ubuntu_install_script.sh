#!/usr/bin/env bash

# Exit immediately if a command fails
set -e

echo "[*] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[*] Installing core build and dev tools..."
sudo apt install -y \
    build-essential \
    git \
    curl \
    wget \
    make \
    gcc \
    g++ \
    perl \
    bzip2 \
    gzip \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

echo "[*] Installing Python and related tools..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    ipython3

echo "[*] Installing VSCode..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code
rm -f packages.microsoft.gpg

echo "[*] Installing Google Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

echo "[*] Installing useful extras..."
sudo apt install -y \
    htop \
    net-tools \
    tmux \
    tree \
    jq \
    vim \
    nano \
    ufw \
    nmap \
    openssh-client \
    gnupg2

echo "[*] Cleaning up..."
sudo apt autoremove -y
sudo apt clean

echo "[*] All done! Installed core dev tools, Chrome, VSCode, Python, Git, build tools, and utilities."
