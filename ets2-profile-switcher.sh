#!/bin/bash

# ETS2 Profile Switcher - Master Script
# Detects Logitech wheel and loads appropriate key bindings

# Configuration - UPDATE THESE PATHS
SCRIPTS_DIR="/home/deck/Projects/sd-ets2-profile-switcher"
ETS2_PROFILES_DIR="/home/deck/.steam/steam/steamapps/compatdata/227300/pfx/drive_c/users/steamuser/Documents/Euro Truck Simulator 2/steam_profiles"

# Config files
WHEEL_CONTROLS_PATH="$SCRIPTS_DIR/wheel-controls.sii"
WHEEL_CONFIG_PATH="$SCRIPTS_DIR/wheel-config.cfg"
DEFAULT_CONTROLS_PATH="$SCRIPTS_DIR/controller-controls.sii"
DEFAULT_CONFIG_PATH="$SCRIPTS_DIR/controller-config.cfg"

# Function to detect Logitech wheel
detect_logitech_wheel() {
    if lsusb | grep -i "logitech.*g29\|logitech.*g920\|logitech.*g923\|logitech.*driving.*force" >/dev/null 2>&1; then
        return 0  # Wheel found
    fi
    return 1  # No wheel found
}

# Get the most recently used profile
get_current_profile() {
    ls -t "$ETS2_PROFILES_DIR" 2>/dev/null | head -n 1
}

# Main execution
CURRENT_PROFILE=$(get_current_profile)

if [ -z "$CURRENT_PROFILE" ]; then
    echo "Error: No ETS2 profile found!"
    notify-send "ETS2 Profile Switcher" "No profile found!" 2>/dev/null
    exit 1
fi

PROFILE_DIR="$ETS2_PROFILES_DIR/$CURRENT_PROFILE"
# Check if profile directory exists
echo $PROFILE_DIR
if [ ! -d "$PROFILE_DIR" ]; then
    echo "Error: Profile directory not found!"
    notify-send "ETS2 Profile Switcher" "Profile directory not found!" 2>/dev/null
    exit 1
fi

# Detect wheel and load appropriate profile
if detect_logitech_wheel; then
    echo "Logitech wheel detected - Loading wheel profile"
    echo $WHEEL_CONTROLS_PATH

    # Copy wheel key bindings
    if [ -f "$WHEEL_CONTROLS_PATH" ]; then
        cp "$WHEEL_CONTROLS_PATH" "$PROFILE_DIR/controls.sii" 2>/dev/null
        echo "Wheel controls loaded"
    fi

    if [ -f "$WHEEL_CONFIG_PATH" ]; then
        cp "$WHEEL_CONFIG_PATH" "$PROFILE_DIR/config_local.cfg" 2>/dev/null
        echo "Wheel config loaded"
    fi

    notify-send "ETS2 Profile Switcher" "Wheel profile loaded 🎮" 2>/dev/null

else
    echo "No Logitech wheel detected - Loading default profile"
    echo $DEFAULT_CONTROLS_PATH

    # Copy default key bindings
    if [ -f "$DEFAULT_CONTROLS_PATH" ]; then
        cp "$DEFAULT_CONTROLS_PATH" "$PROFILE_DIR/controls.sii" 2>/dev/null
        echo "Default controls loaded"
    fi

    if [ -f "$DEFAULT_CONFIG_PATH" ]; then
        cp "$DEFAULT_CONFIG_PATH" "$PROFILE_DIR/config_local.cfg" 2>/dev/null
        echo "Default config loaded"
    fi

    notify-send "ETS2 Profile Switcher" "Default profile loaded ⌨️" 2>/dev/null
fi

echo "Profile switching complete - launching ETS2"
exit 0
