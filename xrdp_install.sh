#!/usr/bin/env bash
set -e

echo "[*] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[*] Installing XRDP..."
sudo apt install -y xrdp

echo "[*] Enabling XRDP service..."
sudo systemctl enable xrdp
sudo systemctl start xrdp

echo "[*] Adding user to ssl-cert group..."
sudo adduser $USER ssl-cert

echo "[*] Installing Ubuntu desktop (if not already installed)..."
# For minimal GNOME desktop (lighter than full ubuntu-desktop)
sudo apt install -y ubuntu-desktop-minimal

echo "[*] Configuring firewall for RDP (port 3389)..."
sudo ufw allow 3389/tcp

echo "[*] Restarting XRDP service..."
sudo systemctl restart xrdp

echo "[*] XRDP installation complete."
echo "👉 You can now connect via RDP client to this machine on port 3389."

