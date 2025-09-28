#!/bin/bash

# Google Chrome Installation Script for Arch Linux
# Installs Google Chrome using the AUR

echo "Installing Google Chrome..."

# Check if we're on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    echo "Error: This script is for Arch Linux only"
    exit 1
fi

# Check if yay is installed (AUR helper)
if ! command -v yay &> /dev/null; then
    echo "Installing yay (AUR helper)..."
    # Install base-devel if not present
    sudo pacman -S --needed --noconfirm base-devel git

    # Clone and install yay
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
else
    echo "yay is already installed"
fi

# Install Google Chrome from AUR
echo "Installing google-chrome from AUR..."
yay -S --noconfirm google-chrome

# Verify installation
if command -v google-chrome-stable &> /dev/null; then
    echo "Google Chrome installed successfully!"
    echo "You can launch it with: google-chrome-stable"
    echo "Or find it in your application menu"
else
    echo "Error: Google Chrome installation failed"
    exit 1
fi

echo "Installation complete!"