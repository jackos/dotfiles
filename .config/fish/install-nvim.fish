#!/usr/bin/fish

# Neovim installation script for macOS and Linux using pre-built binaries

set -l nvim_version "v0.10.2"
set -l install_dir "$HOME/.local/nvim"

# Detect OS and architecture
set -l os (uname -s | tr '[:upper:]' '[:lower:]')
set -l arch (uname -m)

# Map architecture names
switch $arch
    case x86_64
        set arch amd64
    case aarch64 arm64
        # Keep as is
    case '*'
        echo "Unsupported architecture: $arch"
        exit 1
end

# Declare variables before switch
set -l download_url
set -l extract_dir

# Set download URL based on OS
switch $os
    case darwin
        set download_url "https://github.com/neovim/neovim/releases/download/$nvim_version/nvim-macos-$arch.tar.gz"
	echo "Installing on macos from: $download_url"
        set extract_dir "nvim-macos-$arch"
    case linux
        set download_url "https://github.com/neovim/neovim/releases/download/$nvim_version/nvim-linux64.tar.gz"
        set extract_dir "nvim-linux64"
	echo "Installing on linux from: $download_url"
    case '*'
        echo "Unsupported operating system: $os"
        exit 1
end

echo "Downloading Neovim $nvim_version for $os-$arch..."

# Download and extract
curl -LO $download_url
tar xzf nvim-*.tar.gz

# Create install directory and move files
mkdir -p (dirname $install_dir)
rm -rf $install_dir
mv $extract_dir $install_dir

# Add to PATH
fish_add_path "$install_dir/bin"

# Clean up
rm nvim-*.tar.gz

# Verify installation
if command -v nvim >/dev/null 2>&1
    echo "Neovim successfully installed to $install_dir!"
    nvim --version | head -n 1
else
    echo "Installation failed. Please check the error messages above."
    exit 1
end
