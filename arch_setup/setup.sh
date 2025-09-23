#!/bin/bash

# Keyboard Backlight Setup Script
# Sets up passwordless keyboard backlight control for Arch Linux

echo "Setting up keyboard backlight control..."

# Check if we're on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    echo "Error: This script is for Arch Linux only"
    exit 1
fi

# Check if keyboard backlight exists
if [[ ! -d /sys/class/leds/tpacpi::kbd_backlight ]]; then
    echo "Error: Keyboard backlight not found at /sys/class/leds/tpacpi::kbd_backlight"
    echo "This script may not work on your hardware"
    exit 1
fi

# Install brightnessctl if not already installed
if ! command -v brightnessctl &> /dev/null; then
    echo "Installing brightnessctl..."
    sudo pacman -S --noconfirm brightnessctl
else
    echo "brightnessctl is already installed"
fi

# Install the ambient light detection script
SCRIPT_DIR="$(dirname "$0")"
if [[ -f "$SCRIPT_DIR/kbd_auto_brightness.sh" ]]; then
    echo "Installing ambient light detection script..."
    sudo cp "$SCRIPT_DIR/kbd_auto_brightness.sh" "/usr/local/bin/kbd_auto_brightness.sh"
    sudo chmod +x "/usr/local/bin/kbd_auto_brightness.sh"
    echo "Installed kbd_auto_brightness.sh to /usr/local/bin/"
else
    echo "Warning: kbd_auto_brightness.sh not found in $SCRIPT_DIR"
fi

# Install and enable systemd service
if [[ -f "$SCRIPT_DIR/kbd-backlight-auto.service" ]]; then
    echo "Installing systemd service..."
    sudo cp "$SCRIPT_DIR/kbd-backlight-auto.service" "/etc/systemd/system/"
    sudo systemctl daemon-reload
    sudo systemctl enable kbd-backlight-auto.service
    sudo systemctl start kbd-backlight-auto.service
    echo "Service enabled and started - running now and will start automatically at boot"
else
    echo "Warning: kbd-backlight-auto.service not found in $SCRIPT_DIR"
fi

echo "Setup complete!"
echo "Available commands:"
echo "  kbdon, kbdlow, kbdoff - Manual keyboard backlight control"
echo "  systemctl status kbd-backlight-auto - Check auto service status"
echo ""
echo "The automatic keyboard backlight service will start at boot (before login screens)"
echo "Your .zshvargr will automatically detect and expose keyboard aliases when brightnessctl is available"