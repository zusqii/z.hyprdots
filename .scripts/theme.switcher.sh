#!/usr/bin/env bash

# ===================================================================
# 🛠️  FUNCTIONS
# ===================================================================

# Function to update VSCodium theme based on selection
update_vscodium() {
    local theme=$1
    case "$theme" in
        "gruvbox")    vsc_theme="Gruvbox Dark Soft" ;;
        "catppuccin") vsc_theme="Catppuccin Mocha" ;;
        "everforest") vsc_theme="Everforest Dark Soft" ;;
        "Matugen")    vsc_theme="Default Dark Modern" ;; 
        *)            vsc_theme="Default Dark Modern" ;;
    esac
    
    # Update settings.json silently
    sed -i "s/\"workbench.colorTheme\": \".*\"/\"workbench.colorTheme\": \"$vsc_theme\"/" "$HOME/.config/VSCodium/User/settings.json"
}

# ===================================================================
# 🎨 SELECTION & SETUP
# ===================================================================

PRESET_DIR="$HOME/.themes/presets"
ROFI_CONF="$HOME/.config/rofi/config.rasi"

# List presets + Add Matugen option
CHOICE=$(ls "$PRESET_DIR" | { cat; echo "Matugen"; } | rofi -dmenu -i -p "󰃟 Theme" -config "$ROFI_CONF")

# Exit if no choice made
[[ -z "$CHOICE" ]] && exit 0

# ===================================================================
# 🖼️  WALLPAPER HANDLING
# ===================================================================

if [ "$CHOICE" == "Matugen" ]; then
    WALL_DIR="$HOME/Pictures/Wallpapers"
else
    WALL_DIR="$HOME/.themes/wallpapers/$CHOICE"
fi

RANDOM_WALL=$(ls "$WALL_DIR" | shuf -n 1)
FULL_PATH="$WALL_DIR/$RANDOM_WALL"

# Apply Wallpaper with SWWW
swww img "$FULL_PATH" --transition-type center --transition-fps 60

# ===================================================================
# 🚀 COLOR GENERATION & SYMLINKING
# ===================================================================

if [ "$CHOICE" == "Matugen" ]; then
    # 1. Generate colors with Matugen
    matugen image "$FULL_PATH"
    
    # 2. Symlink to Matugen's generated outputs
    ln -sf "$HOME/.config/matugen/generated/colors.rasi" "$HOME/.config/rofi/colors.rasi"
    ln -sf "$HOME/.config/matugen/generated/theme.css" "$HOME/.config/waybar/theme.css"
    ln -sf "$HOME/.config/matugen/generated/kitty.conf" "$HOME/.config/kitty/theme.conf"
    
    # 3. Update Spotify to use the Matugen Color Scheme
    if pgrep -x "spotify" > /dev/null; then
        spicetify config current_theme Sleek color_scheme Matugen
        spicetify apply -q
    fi
else
    # 1. Symlink to Hardcoded Presets
    ln -sf "$PRESET_DIR/$CHOICE/rofi/colors.rasi" "$HOME/.config/rofi/colors.rasi"
    ln -sf "$PRESET_DIR/$CHOICE/waybar/theme.css" "$HOME/.config/waybar/theme.css"
    ln -sf "$PRESET_DIR/$CHOICE/kitty/theme.conf" "$HOME/.config/kitty/theme.conf"
    
    # 2. Update VSCodium
    update_vscodium "$CHOICE"
    
    # 3. Update Spotify (Spicetify)
    if pgrep -x "spotify" > /dev/null; then
        case "$CHOICE" in
            "gruvbox")    spicetify config current_theme Sleek color_scheme gruvbox ;;
            "catppuccin") spicetify config current_theme Sleek color_scheme mocha ;;
            "everforest") spicetify config current_theme Sleek color_scheme everforest ;;
            *)            spicetify config current_theme Sleek color_scheme ultra-dark ;;
        esac
        spicetify apply -q
    fi
fi

# ===================================================================
# 🔄 REFRESH INTERFACE
# ===================================================================

# Refresh Waybar
killall waybar && waybar &

# Refresh Kitty colors without closing terminal
if pgrep -x "kitty" > /dev/null; then
    kill -SIGUSR1 $(pgrep kitty)
fi

# Send notification with the new wallpaper as icon
notify-send -a "System" "Theme updated to $CHOICE" -i "$FULL_PATH"
