#!/bin/bash

set -e

# Get the current username
username=$(whoami)

echo "[+] Updating and upgrading packages..."
sudo apt update
sudo apt full-upgrade -y

echo "[+] Setting Kali repository..."
sudo rm -rf /etc/apt/sources.list
echo "deb [trusted=yes] https://http.kali.org/kali kali-rolling main contrib non-free" | sudo tee /etc/apt/sources.list

echo "[+] Updating with Kali sources..."
sudo apt update

echo "[+] Installing Kali core packages..."
sudo apt install -y kali-defaults
sudo apt install -y kali-desktop-xfce -o Dpkg::Options::="--force-overwrite"
sudo apt install -y synaptic xserver-xephyr kali-wallpapers-2024 ffmpeg notification-daemon

echo "[+] Replacing default XFCE notifier..."
mkdir -p ~/hold
cd /etc/xdg/autostart
sudo mv xfce4-notifyd.desktop ~/hold/ || true

cd /usr/share/applications
sudo cp notification-daemon.desktop /etc/xdg/autostart/

echo "[+] Ensuring /usr/bin/gox is executable..."
sudo chmod +x /usr/bin/gox

echo "[+] Starting Xephyr display environment..."
/usr/bin/gox Xephyr -br -fullscreen -resizeable :20 &

sleep 3

echo "[+] Restarting networking..."
sudo systemctl restart networking &> /dev/null || true

sleep 3

echo "[+] Launching XFCE in Xephyr..."
sudo -u "$username" env \
  XDG_RUNTIME_DIR="/run/user/$(id -u $username)" \
  GDK_BACKEND=x11 \
  PATH="/usr/local/bin:/usr/bin:/usr/local/games:/usr/games" \
  DISPLAY=:20 \
  startxfce4 &> /dev/null &

echo "[✓] Kali XFCE setup complete and running inside Xephyr."
