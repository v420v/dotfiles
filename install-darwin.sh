#!/usr/bin/env bash
# Bootstrap a fresh macOS install onto this rice (nix-darwin + home-manager).
#
# Assumes:
#   - This repo is checked out at ~/dotfiles (path is referenced by HM).
#   - You are running on macOS (Apple Silicon or Intel).
#
# After the first switch, day-to-day rebuilds are just:
#   sudo darwin-rebuild switch --flake ~/dotfiles#"$USER"

set -euo pipefail
DOTS="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# 1. Verify Nix is available.
if ! command -v nix >/dev/null 2>&1; then
    echo "Nix is not installed. Install it first:"
    echo "  https://nixos.org/download/#nix-install-macos"
    exit 1
fi

# 2. Enable flakes if not already set.
NIX_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/nix/nix.conf"
if ! grep -qF 'experimental-features' "$NIX_CONF" 2>/dev/null; then
    echo "Enabling flakes in $NIX_CONF ..."
    mkdir -p "$(dirname "$NIX_CONF")"
    echo 'experimental-features = nix-command flakes' >> "$NIX_CONF"
fi

# 3. Confirm before running the first (slow) rebuild.
echo
echo "Will run:"
echo "  sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake $DOTS#$USER"
echo
read -r -p "Proceed? [y/N] " ans
case "${ans,,}" in
    y | yes)
        sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake "$DOTS#$USER"
        ;;
    *)
        echo "Skipped. Run when ready:"
        echo "  sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake $DOTS#$USER"
        exit 0
        ;;
esac

# 4. Print rebuild hint for subsequent runs.
echo
echo "Done. For subsequent rebuilds:"
echo "  sudo darwin-rebuild switch --flake $DOTS#$USER          # full system"
echo "  home-manager switch --flake $DOTS#${USER}@mac           # user-only (no sudo)"
