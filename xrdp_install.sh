#!/usr/bin/env bash
set -euo pipefail

# --- Config toggles ---
DISABLE_WAYLAND=true     # Safer for xRDP on Ubuntu with GDM
ENABLE_SOUND=true        # pulseaudio over RDP (works on most Ubuntu releases)

echo "[*] Updating system..."
sudo apt update && sudo apt -y upgrade

echo "[*] Installing XRDP + Xorg backend..."
sudo apt install -y xrdp xorgxrdp

echo "[*] Installing a better desktop for RDP: XFCE4 (+ goodies)..."
sudo apt install -y xfce4 xfce4-goodies dbus-x11 x11-xserver-utils

# Optional but useful fonts for better rendering over RDP
sudo apt install -y fonts-dejavu fonts-liberation || true

# Add current user to ssl-cert (xrdp cert access)
TARGET_USER="${SUDO_USER:-$USER}"
echo "[*] Adding ${TARGET_USER} to ssl-cert group..."
sudo adduser "${TARGET_USER}" ssl-cert

# Make sure user session launches XFCE when coming via xRDP
USER_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"
echo "[*] Setting ${USER_HOME}/.xsession to start XFCE..."
echo "xfce4-session" | sudo tee "${USER_HOME}/.xsession" >/dev/null
sudo chown "${TARGET_USER}:${TARGET_USER}" "${USER_HOME}/.xsession"

# (Optional) Disable Wayland on GDM; xRDP uses Xorg
if $DISABLE_WAYLAND; then
  if [ -f /etc/gdm3/custom.conf ]; then
    echo "[*] Disabling Wayland in /etc/gdm3/custom.conf..."
    sudo sed -i 's/^#\?\s*WaylandEnable=.*/WaylandEnable=false/' /etc/gdm3/custom.conf
    # If the key wasn't present, append it:
    grep -q '^WaylandEnable=false' /etc/gdm3/custom.conf || echo 'WaylandEnable=false' | sudo tee -a /etc/gdm3/custom.conf >/dev/null
  fi
fi

# Sound redirection over RDP (if available on this Ubuntu)
if $ENABLE_SOUND; then
  echo "[*] Installing pulseaudio module for xRDP (sound over RDP)..."
  if sudo apt install -y pulseaudio-module-xrdp; then
    echo "[*] pulseaudio-module-xrdp installed."
  else
    echo "[!] Could not install pulseaudio-module-xrdp (not available on this release). Skipping sound."
  fi
fi

echo "[*] Enabling and starting xrdp service..."
sudo systemctl enable xrdp
sudo systemctl restart xrdp

# Open firewall only if UFW is active
if command -v ufw >/dev/null 2>&1 && sudo ufw status | grep -q "Status: active"; then
  echo "[*] UFW detected and active. Allowing TCP 3389..."
  sudo ufw allow 3389/tcp
else
  echo "[*] UFW not active (or not installed). Skipping firewall change."
fi

# Clean up
echo "[*] Cleaning up..."
sudo apt -y autoremove
sudo apt -y clean

echo "==============================================================="
echo "[✓] XRDP + XFCE ready."
echo "    - RDP to this host on TCP 3389."
echo "    - Log in as: ${TARGET_USER}"
echo "    - Session will launch XFCE (fast & xRDP-friendly)."
$DISABLE_WAYLAND && echo "    - Wayland disabled for compatibility."
$ENABLE_SOUND && echo "    - Sound redirection attempted via pulseaudio-module-xrdp."
echo "Tip: If you get a black screen, log out, then choose 'Xorg' at the login."
echo "==============================================================="
