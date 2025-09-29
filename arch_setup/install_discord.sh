#!/bin/bash

# Discord Installation Script for Arch Linux
# Installs Discord using the official package

echo "Installing Discord..."

# Check if we're on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    echo "Error: This script is for Arch Linux only"
    exit 1
fi

# Check if Discord is already installed
if command -v discord &> /dev/null; then
    echo "Discord is already installed"
    echo "Current version: $(discord --version 2>/dev/null || echo 'unknown')"
    read -p "Do you want to update Discord? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping installation."
        exit 0
    fi
fi

# Update package database
echo "Updating package database..."
sudo pacman -Sy

# Install Discord from official repositories
echo "Installing discord from official repositories..."
sudo pacman -S --needed --noconfirm discord

# Verify installation
if command -v discord &> /dev/null; then
    echo "Discord installed successfully!"
    echo "Version: $(discord --version 2>/dev/null || echo 'installed')"
    echo "You can launch it with: discord"
    echo "Or find it in your application menu"
else
    echo "Error: Discord installation failed"
    exit 1
fi

echo "Installation complete!"