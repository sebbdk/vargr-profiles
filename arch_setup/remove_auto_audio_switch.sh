#!/bin/bash

# Remove automatic audio profile switching service

echo "Removing automatic audio jack detection service..."
echo ""

# Stop and disable the service
if systemctl --user is-active --quiet audio-jack-monitor.service; then
    echo "Stopping audio-jack-monitor service..."
    systemctl --user stop audio-jack-monitor.service
fi

if systemctl --user is-enabled --quiet audio-jack-monitor.service 2>/dev/null; then
    echo "Disabling audio-jack-monitor service..."
    systemctl --user disable audio-jack-monitor.service
fi

# Remove service file
if [ -f ~/.config/systemd/user/audio-jack-monitor.service ]; then
    echo "Removing service file..."
    rm ~/.config/systemd/user/audio-jack-monitor.service
fi

# Remove monitor script
if [ -f ~/.local/bin/audio-jack-monitor.sh ]; then
    echo "Removing monitor script..."
    rm ~/.local/bin/audio-jack-monitor.sh
fi

# Reload systemd
systemctl --user daemon-reload

echo ""
echo "✓ Automatic audio jack detection has been removed"
echo ""
echo "Your audio will now use the default system behavior."
echo "You can manually switch profiles using pavucontrol or by running:"
echo "  pactl set-card-profile <card> <profile>"
echo ""