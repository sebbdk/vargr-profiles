#!/bin/bash

# Manual audio output toggle
# Forces switch between speakers and headphones

CARD_NUM=1
SPEAKER_PROFILE="HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)"
HEADPHONE_PROFILE="HiFi (HDMI1, HDMI2, HDMI3, Headphones, Mic1, Mic2)"

# Get current profile
CURRENT_PROFILE=$(pactl list cards | grep -A 10 "Card #$CARD_NUM" | grep "Active Profile" | cut -d: -f2- | sed 's/^[ \t]*//')

if echo "$CURRENT_PROFILE" | grep -q "Speaker"; then
    echo "Switching to Headphones..."
    pactl set-card-profile $CARD_NUM "$HEADPHONE_PROFILE"
    sleep 0.5
    HEADPHONE_SINK=$(pactl list sinks short | grep "HiFi__Headphones__sink" | awk '{print $2}')
    if [ -n "$HEADPHONE_SINK" ]; then
        pactl set-default-sink "$HEADPHONE_SINK"
        pactl set-sink-mute "$HEADPHONE_SINK" 0
        pactl set-sink-volume "$HEADPHONE_SINK" 80%
    fi
    echo "✓ Switched to Headphones"
else
    echo "Switching to Speakers..."
    pactl set-card-profile $CARD_NUM "$SPEAKER_PROFILE"
    sleep 0.5
    SPEAKER_SINK=$(pactl list sinks short | grep "HiFi__Speaker__sink" | awk '{print $2}')
    if [ -n "$SPEAKER_SINK" ]; then
        pactl set-default-sink "$SPEAKER_SINK"
        pactl set-sink-mute "$SPEAKER_SINK" 0
        pactl set-sink-volume "$SPEAKER_SINK" 80%
    fi
    echo "✓ Switched to Speakers"
fi

# Restart monitor to sync state
systemctl --user restart audio-jack-monitor 2>/dev/null