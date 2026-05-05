#!/usr/bin/env bash
# Bootstrap a fresh NixOS install onto this rice.
#
# Assumes:
#   - You ran `nixos-install` and rebooted into the new system.
#   - This repo is checked out at ~/dotfiles (path is referenced by HM).
#   - `hardware-configuration.nix` exists at /etc/nixos/.
#
# After the first switch, day-to-day rebuilds are just:
#   sudo nixos-rebuild switch --flake ~/dotfiles#nixos

set -euo pipefail
DOTS="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# Pull the live hardware-configuration into the repo so the flake can see it.
if [ ! -f "$DOTS/nixos/hardware-configuration.nix" ]; then
    echo "Importing /etc/nixos/hardware-configuration.nix into repo ..."
    sudo cp /etc/nixos/hardware-configuration.nix "$DOTS/nixos/hardware-configuration.nix"
    sudo chown "$USER:" "$DOTS/nixos/hardware-configuration.nix"
fi

# Generate wallpaper if missing and ImageMagick is available.
if [ ! -f "$DOTS/wallpapers/wall.png" ]; then
    if command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1; then
        echo "Generating wallpaper ..."
        bash "$DOTS/wallpapers/generate.sh"
    else
        echo "Skipping wallpaper generation (ImageMagick not installed yet)."
        echo "Re-run this script after the first nixos-rebuild."
    fi
fi

echo
read -r -p "Run nixos-rebuild switch --flake $DOTS#nixos now? [y/N] " ans
case "${ans,,}" in
    y|yes) sudo nixos-rebuild switch --flake "$DOTS#nixos" ;;
    *)     echo "Skipped. Run when ready: sudo nixos-rebuild switch --flake $DOTS#nixos" ;;
esac

echo "Done."
