#!/usr/bin/env bash
# pipewire-xrdp-setup.sh
# Ubuntu 24.04+ / 25.04 — Fresh install with XRDP audio via PipeWire
# Author: A
# License: MIT

# --- Auto‑strip CRLF if present ---
if grep -q $'\r' "$0"; then
  printf "🔧 Detected Windows (CRLF) line endings — normalizing to Unix (LF)...\n"
  # Backup original just in case
  cp "$0" "$0.bak"
  # Strip carriage returns in place
  sed -i 's/\r$//' "$0"
  exec bash "$0" "$@"
fi

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

echo "🔍 Verifying XRDP audio stream in PipeWire..."

# Bail out early if PipeWire daemon isn't up in this session
if ! systemctl --user --quiet is-active pipewire; then
  echo "⚠️ PipeWire is not running in this session."
  echo "   If you are in the Hyper-V console, reconnect via RDP with audio enabled and retry:"
  echo "      check-xrdp-audio"
  exit 0
fi

# Detect if we're *not* in an XRDP session
if [ -z "$XRDP_SESSION" ] && ! loginctl show-session "$XDG_SESSION_ID" -p Type | grep -qi xrdp; then
  echo "ℹ️ No XRDP login detected — skipping live audio check."
  echo "   Reconnect over RDP with audio redirection to test."
  exit 0
fi

# Run actual search with a timeout to avoid indefinite hang
if ! timeout 5 pw-cli ls Node | grep -A4 -i xrdp; then
  echo "⚠️ No XRDP audio node detected — check your RDP client audio settings."
fi


########################################
# 7️⃣ Add diagnostic alias
########################################
echo "🩺 Creating 'check-xrdp-audio' alias..."
CHECK_CMD="pw-cli ls Node | grep -A4 -i xrdp || echo \"⚠️ No XRDP audio node detected — check RDP client audio settings.\""
if ! grep -q "check-xrdp-audio" ~/.bashrc; then
  echo "alias check-xrdp-audio='$CHECK_CMD'" >> ~/.bashrc
fi

########################################
# ✅ Done
########################################
echo "Setup complete. Reconnect via RDP with clipboard + audio enabled."
echo "Look for 'xrdp-sink' above to confirm audio redirection."
echo "You can re-run the diagnostic anytime by typing: check-xrdp-audio"




