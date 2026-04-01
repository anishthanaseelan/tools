#!/usr/bin/env bash
# Setup script for a new dev VM (Ubuntu)
# Run: chmod +x setup-dev-vm.sh && sudo ./setup-dev-vm.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use sudo)."
    exit 1
fi

ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")

run_as_user() {
    sudo -u "$ACTUAL_USER" "$@"
}

echo "=== Dev VM Setup (Ubuntu) ==="

apt-get update

# --- Google Chrome ---
echo -e "\n--- Installing Google Chrome ---"
wget -qO /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get install -y /tmp/google-chrome.deb
rm -f /tmp/google-chrome.deb
echo "Google Chrome installed."

# --- Git ---
echo -e "\n--- Installing Git ---"
apt-get install -y git
echo "Git installed."

# --- Python ---
echo -e "\n--- Installing Python ---"
apt-get install -y python3 python3-pip python3-venv
echo "Python installed."

# --- VS Code ---
echo -e "\n--- Installing VS Code ---"
apt-get install -y wget gpg apt-transport-https
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
apt-get update
apt-get install -y code
echo "VS Code installed."

# --- Node.js LTS (required for Claude Code) ---
echo -e "\n--- Installing Node.js LTS ---"
if ! command -v node &>/dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs
fi
echo "Node.js $(node --version) installed."

# --- Claude Code (CLI) ---
echo -e "\n--- Installing Claude Code ---"
run_as_user npm install -g @anthropic-ai/claude-code
echo "Claude Code installed."

# --- Claude Desktop ---
echo -e "\n--- Installing Claude Desktop ---"
wget -qO /tmp/claude-desktop.deb https://storage.googleapis.com/anthropic-desktop/claude-desktop/latest/claude-desktop_amd64.deb
apt-get install -y /tmp/claude-desktop.deb
rm -f /tmp/claude-desktop.deb
echo "Claude Desktop installed."

echo -e "\n=== Setup complete! ==="
echo "You may need to log out and back in for PATH changes to take effect."
