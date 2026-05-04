#!/usr/bin/env bash
# Symlink dotfiles into ~/.config and apply NixOS system config.
# Idempotent: re-running just refreshes the links.

set -euo pipefail
DOTS="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
CFG="$HOME/.config"
mkdir -p "$CFG"

link() {
    local src="$1" dst="$2"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        local bak="${dst}.bak.$(date +%s)"
        echo "  backing up existing $dst -> $bak"
        mv "$dst" "$bak"
    fi
    ln -sfn "$src" "$dst"
    echo "  $dst -> $src"
}

echo "Linking user configs into $CFG ..."
link "$DOTS/hypr"                   "$CFG/hypr"
link "$DOTS/waybar"                 "$CFG/waybar"
link "$DOTS/kitty"                  "$CFG/kitty"
link "$DOTS/rofi"                   "$CFG/rofi"
link "$DOTS/dunst"                  "$CFG/dunst"
link "$DOTS/fastfetch"              "$CFG/fastfetch"
link "$DOTS/nvim"                   "$CFG/nvim"
link "$DOTS/starship/starship.toml" "$CFG/starship.toml"

# zsh lives at $HOME, not $CFG
link "$DOTS/zsh/.zshrc"             "$HOME/.zshrc"

# Generate wallpaper if missing and ImageMagick is available.
if [ ! -f "$DOTS/wallpapers/wall.png" ]; then
    if command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1; then
        echo "Generating wallpaper ..."
        bash "$DOTS/wallpapers/generate.sh"
    else
        echo "Skipping wallpaper generation (ImageMagick not installed yet — run nixos-rebuild first)."
    fi
fi

# Apply NixOS system config.
echo
read -r -p "Apply NixOS system config to /etc/nixos and rebuild now? [y/N] " ans
case "${ans,,}" in
    y|yes)
        # Preserve the auto-generated hardware config.
        sudo install -d -m 0755 /etc/nixos
        if [ ! -f "$DOTS/nixos/hardware-configuration.nix" ]; then
            sudo cp /etc/nixos/hardware-configuration.nix "$DOTS/nixos/hardware-configuration.nix"
        fi
        sudo cp "$DOTS/nixos/configuration.nix"          /etc/nixos/configuration.nix
        sudo cp "$DOTS/nixos/hardware-configuration.nix" /etc/nixos/hardware-configuration.nix
        sudo nixos-rebuild switch
        ;;
    *)
        echo "Skipped system rebuild. To apply later:"
        echo "  sudo cp $DOTS/nixos/configuration.nix /etc/nixos/configuration.nix"
        echo "  sudo nixos-rebuild switch"
        ;;
esac

echo "Done."
