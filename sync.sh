#!/usr/bin/env bash

REPO_DIR="/home/zusqii/z.hyprdots"
CONF_DIR="$HOME/.config"

mkdir -p "$REPO_DIR"/.config

items=(cava clock-rs fastfetch hypr kitty matugen rofi swaync waybar wayclick wlogout)

for item in "${items[@]}"; do
    if [ -d "$CONF_DIR/$item" ]; then
        cp -r "$CONF_DIR/$item" "$REPO_DIR/.config/"
        echo "✅ Copied $item"
    else
        echo "⚠️  Missing $item"
    fi
done

cp "$HOME/.zshrc" "$REPO_DIR/"
cp -r "$HOME/.scripts" "$REPO_DIR/"
cp -r "$HOME/.themes" "$REPO_DIR/"
cp -r "$HOME/Pictures/Wallpapers" "$REPO_DIR/"

cd "$REPO_DIR" || exit

git add .

if git diff-index --quiet HEAD --; then
    echo "✨ No changes to push."
else
    git commit -m "Update dots: $(date +'%Y-%m-%d %H:%M')"
    git push origin main
    echo "🎉 Pushed to GitHub!"
fi
