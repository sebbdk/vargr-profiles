#!/bin/bash

# Ambient light detection for automatic keyboard backlight
# Uses webcam to detect darkness and adjust keyboard backlight accordingly
# Runs continuously in background

BRIGHTNESS_THRESHOLD=30  # Adjust this value (0-100, lower = darker needed to trigger)
WEBCAM_DEVICE="/dev/video0"
TEMP_IMAGE="/tmp/webcam_brightness_check.jpg"
CHECK_INTERVAL=60  # Check every 60 seconds

echo "Starting automatic keyboard backlight control..."
echo "Brightness threshold: $BRIGHTNESS_THRESHOLD%"
echo "Check interval: ${CHECK_INTERVAL}s"

while true; do
    # Check if webcam exists
    if [[ ! -e "$WEBCAM_DEVICE" ]]; then
        echo "Warning: Webcam not found at $WEBCAM_DEVICE, retrying in ${CHECK_INTERVAL}s..."
        sleep "$CHECK_INTERVAL"
        continue
    fi

    # Take a quick photo and analyze brightness
    if ffmpeg -f v4l2 -i "$WEBCAM_DEVICE" -vframes 1 -y "$TEMP_IMAGE" 2>/dev/null; then

        # Calculate average brightness using ImageMagick (if available) or ffmpeg
        if command -v identify &> /dev/null; then
            BRIGHTNESS=$(identify -format "%[fx:int(100*mean)]" "$TEMP_IMAGE" 2>/dev/null)
        else
            # Fallback: use ffmpeg to get brightness
            BRIGHTNESS=$(ffmpeg -i "$TEMP_IMAGE" -vf "select=eq(n\,0),format=gray,crop=iw/3:ih/3:iw/3:ih/3,scale=1:1" -f rawvideo - 2>/dev/null | od -An -tu1 | awk '{sum+=$1} END {print int(sum/NR*100/255)}')
        fi

        # Clean up temp file
        rm -f "$TEMP_IMAGE"

        echo "$(date '+%Y-%m-%d %H:%M:%S') - Detected brightness: $BRIGHTNESS%"

        # Adjust keyboard backlight based on ambient light
        if [[ "$BRIGHTNESS" -lt "$BRIGHTNESS_THRESHOLD" ]]; then
            echo "Dark environment detected, turning on keyboard backlight"
            brightnessctl -d tpacpi::kbd_backlight s 2 2>/dev/null
        else
            echo "Bright environment detected, turning off keyboard backlight"
            brightnessctl -d tpacpi::kbd_backlight s 0 2>/dev/null
        fi
    else
        echo "Failed to capture image from webcam, retrying in ${CHECK_INTERVAL}s..."
    fi

    sleep "$CHECK_INTERVAL"
done