#!/usr/bin/env bash
# Generate a Catppuccin Mocha gradient wallpaper.
# Requires: ImageMagick (`magick` or `convert`).

set -euo pipefail
out="$(dirname "$(readlink -f "$0")")/wall.png"

if command -v magick >/dev/null 2>&1; then
    IM=magick
elif command -v convert >/dev/null 2>&1; then
    IM=convert
else
    echo "ImageMagick not found — install it (e.g. nixos-rebuild) and rerun." >&2
    exit 1
fi

# 1920x1080 diagonal gradient: mauve -> base -> blue, with a soft vignette.
$IM -size 1920x1080 \
    gradient:'#cba6f7-#1e1e2e' \
    \( -size 1920x1080 gradient:'#89b4fa-none' -rotate -25 \) \
    -compose Overlay -composite \
    \( -size 1920x1080 radial-gradient:'none-#11111baa' \) \
    -compose Multiply -composite \
    -modulate 95,110,100 \
    "$out"

echo "Wrote $out"
