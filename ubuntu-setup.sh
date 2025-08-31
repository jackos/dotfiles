#!/bin/bash

# Update and install packages
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update
sudo apt upgrade -y
sudo apt install -y python3-venv cmake fish ripgrep fd-find

# Install Lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  LAZYGIT_ARCH="Linux_x86_64"
elif [ "$ARCH" = "aarch64" ]; then
  LAZYGIT_ARCH="Linux_arm64"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_${LAZYGIT_ARCH}.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz lazygit

