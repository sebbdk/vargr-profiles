#!/bin/bash

# Screen Sharing Setup Script for Arch Linux
# Installs PipeWire and xdg-desktop-portal for screen sharing support

echo "Setting up screen sharing for Arch Linux..."

# Check if we're on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    echo "Error: This script is for Arch Linux only"
    exit 1
fi

# Detect desktop environment/window manager
detect_de() {
    if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
        echo "gnome"
    elif [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]] || [[ "$XDG_CURRENT_DESKTOP" == *"plasma"* ]]; then
        echo "kde"
    elif [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        echo "wlroots"
    else
        echo "gtk"
    fi
}

DE=$(detect_de)
echo "Detected desktop environment: $DE"

# Update package database
echo "Updating package database..."
sudo pacman -Sy

# Check for PulseAudio and remove it if present
if pacman -Qi pulseaudio &> /dev/null; then
    echo "PulseAudio detected. Removing to install PipeWire..."
    sudo pacman -Rdd --noconfirm pulseaudio
fi

# Upgrade any outdated PipeWire-related packages first
echo "Checking for PipeWire package updates..."
if pacman -Qi gst-plugin-pipewire &> /dev/null || pacman -Qi pipewire-alsa &> /dev/null; then
    echo "Upgrading PipeWire-related packages..."
    sudo pacman -Syu --noconfirm
fi

# Install PipeWire and related packages
echo "Installing PipeWire stack..."
sudo pacman -S --needed --noconfirm \
    pipewire \
    pipewire-audio \
    pipewire-pulse \
    pipewire-jack \
    pipewire-alsa \
    gst-plugin-pipewire \
    wireplumber \
    xdg-desktop-portal

# Install appropriate xdg-desktop-portal backend
case $DE in
    gnome)
        echo "Installing xdg-desktop-portal-gnome..."
        sudo pacman -S --needed --noconfirm xdg-desktop-portal-gnome
        ;;
    kde)
        echo "Installing xdg-desktop-portal-kde..."
        sudo pacman -S --needed --noconfirm xdg-desktop-portal-kde
        ;;
    wlroots)
        echo "Installing xdg-desktop-portal-wlr (for wlroots-based compositors)..."
        sudo pacman -S --needed --noconfirm xdg-desktop-portal-wlr
        ;;
    *)
        echo "Installing xdg-desktop-portal-gtk (generic fallback)..."
        sudo pacman -S --needed --noconfirm xdg-desktop-portal-gtk
        ;;
esac

# Enable and start PipeWire services
echo "Enabling PipeWire services..."
systemctl --user enable --now pipewire.service
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now wireplumber.service

# Configure xdg-desktop-portal for wlroots-based compositors
if [[ "$DE" == "wlroots" ]]; then
    echo "Configuring xdg-desktop-portal for wlroots..."
    mkdir -p ~/.config/xdg-desktop-portal

    # Detect specific compositor for better config naming
    COMPOSITOR="sway"
    if pgrep -x "hyprland" > /dev/null; then
        COMPOSITOR="hyprland"
    elif pgrep -x "river" > /dev/null; then
        COMPOSITOR="river"
    fi

    cat > ~/.config/xdg-desktop-portal/${COMPOSITOR}-portals.conf << 'EOF'
[preferred]
default=wlr;gtk
org.freedesktop.impl.portal.ScreenCast=wlr
org.freedesktop.impl.portal.Screenshot=wlr
EOF
    echo "Created portal configuration: ~/.config/xdg-desktop-portal/${COMPOSITOR}-portals.conf"
fi

# Restart xdg-desktop-portal to ensure it picks up the new backend
echo "Restarting xdg-desktop-portal..."
systemctl --user restart xdg-desktop-portal.service 2>/dev/null || true

# Verify installation
echo ""
echo "Verifying installation..."
if systemctl --user is-active --quiet pipewire.service; then
    echo "✓ PipeWire is running"
else
    echo "✗ PipeWire is not running"
fi

if systemctl --user is-active --quiet wireplumber.service; then
    echo "✓ WirePlumber is running"
else
    echo "✗ WirePlumber is not running"
fi

if pacman -Qi xdg-desktop-portal &> /dev/null; then
    echo "✓ xdg-desktop-portal is installed"
else
    echo "✗ xdg-desktop-portal is not installed"
fi

echo ""
echo "Screen sharing setup complete!"
echo ""
echo "Notes:"
echo "- You may need to log out and log back in for changes to take full effect"
echo "- Screen sharing should now work in apps like Discord, Chrome, Firefox, etc."
echo "- For Sway/wlroots: Window sharing is now configured via portal config"
echo ""
echo "To test screen sharing:"
echo "1. Open Chrome/Firefox and go to a video call site"
echo "2. Try to share your screen"
echo "3. You should see a portal dialog to select which screen/window to share"