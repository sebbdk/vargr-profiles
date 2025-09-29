#!/bin/bash

# Setup automatic audio profile switching based on headphone jack detection
# Hardware agnostic - works on any laptop with Arch Linux

echo "Setting up automatic headphone jack detection..."
echo ""

# Check if pactl is available
if ! command -v pactl &> /dev/null; then
    echo "Error: pactl is not installed"
    echo "Install with: sudo pacman -S libpulse"
    exit 1
fi

echo "✓ pactl is available"
echo ""

# Find the internal audio card (not USB devices)
CARD_INFO=$(pactl list cards short | grep -v "usb" | grep "alsa_card" | head -1)
CARD_NUM=$(echo "$CARD_INFO" | awk '{print $1}')
CARD_NAME=$(echo "$CARD_INFO" | awk '{print $2}')

if [ -z "$CARD_NUM" ]; then
    echo "Error: Could not find internal audio card"
    exit 1
fi

echo "Found internal audio card: $CARD_NAME (card $CARD_NUM)"
echo ""

# Get available profiles
SPEAKER_PROFILE=$(pactl list cards | grep -A 100 "$CARD_NAME" | grep "HiFi.*Speaker" | head -1 | sed 's/^[ \t]*//' | cut -d: -f1)
HEADPHONE_PROFILE=$(pactl list cards | grep -A 100 "$CARD_NAME" | grep "HiFi.*Headphones" | head -1 | sed 's/^[ \t]*//' | cut -d: -f1)

if [ -z "$SPEAKER_PROFILE" ] || [ -z "$HEADPHONE_PROFILE" ]; then
    echo "Error: Could not find speaker or headphone profiles"
    exit 1
fi

echo "Speaker profile: $SPEAKER_PROFILE"
echo "Headphone profile: $HEADPHONE_PROFILE"
echo ""

# Create the monitor script
mkdir -p ~/.local/bin

cat > ~/.local/bin/audio-jack-monitor.sh << EOF
#!/bin/bash
# Automatic audio profile switcher based on headphone jack detection

CARD_NUM=$CARD_NUM
SPEAKER_PROFILE="$SPEAKER_PROFILE"
HEADPHONE_PROFILE="$HEADPHONE_PROFILE"

# Monitor PulseAudio/PipeWire events
pactl subscribe | while read -r event; do
    # Check for card change events
    if echo "\$event" | grep -q "Event 'change' on card"; then
        # Small delay to let the hardware settle
        sleep 0.2

        # Check if headphones are plugged in by looking for "available" status
        HEADPHONE_AVAILABLE=\$(pactl list cards | grep -A 200 "Card #\$CARD_NUM" | grep "Headphones:" | grep "available")

        # Get current profile
        CURRENT_PROFILE=\$(pactl list cards | grep -A 10 "Card #\$CARD_NUM" | grep "Active Profile" | cut -d: -f2- | sed 's/^[ \t]*//')

        if [ -n "\$HEADPHONE_AVAILABLE" ]; then
            # Headphones are plugged in
            if ! echo "\$CURRENT_PROFILE" | grep -q "Headphones"; then
                echo "\$(date): Headphones plugged in - switching to headphones profile"
                pactl set-card-profile \$CARD_NUM "\$HEADPHONE_PROFILE"
            fi
        else
            # Headphones are unplugged
            if echo "\$CURRENT_PROFILE" | grep -q "Headphones"; then
                echo "\$(date): Headphones unplugged - switching to speaker profile"
                pactl set-card-profile \$CARD_NUM "\$SPEAKER_PROFILE"
            fi
        fi
    fi
done
EOF

chmod +x ~/.local/bin/audio-jack-monitor.sh

echo "✓ Created audio jack monitor script"
echo ""

# Create systemd user service
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/audio-jack-monitor.service << EOF
[Unit]
Description=Automatic Audio Profile Switcher
After=pipewire.service wireplumber.service

[Service]
Type=simple
ExecStart=%h/.local/bin/audio-jack-monitor.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

echo "✓ Created systemd service"
echo ""

# Enable and start the service
systemctl --user daemon-reload
systemctl --user enable audio-jack-monitor.service
systemctl --user start audio-jack-monitor.service

echo "✓ Service enabled and started"
echo ""

# Check service status
if systemctl --user is-active --quiet audio-jack-monitor.service; then
    echo "✓ Audio jack monitoring is now active!"
    echo ""
    echo "Your system will now automatically:"
    echo "  • Switch to headphones when you plug them in"
    echo "  • Switch to speakers when you unplug headphones"
    echo ""
    echo "Service management commands:"
    echo "  • Check status: systemctl --user status audio-jack-monitor"
    echo "  • View logs: journalctl --user -u audio-jack-monitor -f"
    echo "  • Stop service: systemctl --user stop audio-jack-monitor"
    echo "  • Disable service: systemctl --user disable audio-jack-monitor"
else
    echo "⚠ Service failed to start. Check logs with:"
    echo "  journalctl --user -u audio-jack-monitor"
fi
echo ""