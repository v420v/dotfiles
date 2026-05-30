#!/usr/bin/env bash
# Generate a macOS-style mountain wallpaper.
# Dusk sky gradient with layered mountain silhouettes (Big Sur vibes),
# tuned for a dark desktop. Requires ImageMagick (`magick` or `convert`).

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

W=2560
H=1440

# Sky = three stacked vertical gradients with matched endpoints (seamless):
#   deep indigo  -> mauve         (upper sky)
#   mauve        -> warm peach    (dusk band)
#   warm peach   -> deep blue     (down to the mountains)
# Then 4 layers of jagged ridge polygons, lightest/hazier in back.
$IM \
    \( \
    \( -size ${W}x600 gradient:'#0f1430-#3a2655' \) \
    \( -size ${W}x420 gradient:'#3a2655-#d4836a' \) \
    \( -size ${W}x420 gradient:'#d4836a-#1a2148' \) \
    -append \
    \) \
    \( -size ${W}x${H} xc:none \
    -fill '#8294c2' \
    -draw "polygon 0,1080 180,980 360,1040 560,900 760,1000 980,920 1180,1010 1400,880 1620,990 1840,920 2060,1010 2280,930 2480,1010 2560,990 2560,1440 0,1440" \
    -blur 0x0.6 \
    -fill '#4f6298' \
    -draw "polygon 0,1180 200,1040 420,1120 640,960 880,1080 1100,980 1320,1100 1560,940 1780,1070 2000,990 2220,1090 2420,980 2560,1060 2560,1440 0,1440" \
    -blur 0x0.4 \
    -fill '#2a3866' \
    -draw "polygon 0,1280 240,1140 460,1240 720,1080 920,1200 1180,1040 1400,1180 1640,1020 1880,1190 2120,1080 2340,1210 2520,1100 2560,1170 2560,1440 0,1440" \
    -fill '#10183a' \
    -draw "polygon 0,1360 280,1240 540,1320 820,1200 1100,1300 1380,1180 1660,1290 1920,1180 2200,1300 2440,1220 2560,1290 2560,1440 0,1440" \
    \) -compose Over -composite \
    \( -size ${W}x${H} radial-gradient:'none-#000000aa' \) -compose Multiply -composite \
    -modulate 96,108,100 \
    "$out"

echo "Wrote $out"
