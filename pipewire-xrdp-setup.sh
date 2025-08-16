#!/usr/bin/env bash
# pipewire-xrdp-setup.sh
# Ubuntu 24.04+ / 25.04 — Fresh install with XRDP audio via PipeWire
# Author: A
# License: MIT

set -e

########################################
# 1️⃣  Update package index
########################################
echo "🔄 Updating package index..."
sudo apt update

########################################
# 2️⃣  Install PipeWire core + extras
########################################
echo "📦 Installing PipeWire core stack..."
sudo apt install -y \
  pipewire \
  pipewire-audio-client-libraries \
  libspa-0.2-bluetooth \
  libspa-0.2-jack \
  wireplumber \
  pipewire-pulse

########################################
# 3️⃣  Install XRDP + PipeWire module
########################################
echo "🎧 Installing XRDP + PipeWire sound module..."
sudo apt install -y xrdp pipewire-module-xrdp

########################################
# 4️⃣  Enable user services for PipeWire
########################################
echo "⚙️ Enabling PipeWire user services..."
systemctl --user --now enable pipewire pipewire-pulse wireplumber

########################################
# 5️⃣  Restart XRDP service
########################################
echo "🔁 Restarting XRDP..."
sudo systemctl restart xrdp

########################################
# 6️⃣  Verify XRDP audio node
########################################
echo "🔍 Verifying XRDP audio stream in PipeWire..."
pw-cli ls Node | grep -A4 -i xrdp || \
  echo "⚠️ No XRDP audio node detected — check your RDP client audio settings."

########################################
# ✅  Done
########################################
echo "Setup complete. Reconnect via RDP with clipboard + audio enabled."
echo "Look for 'xrdp-sink' in the verification above to confirm audio redirection."
