#!/usr/bin/env bash
# In-place formatters. Run inside `nix develop` so every tool is on PATH.
set -uo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
cd "$ROOT" || exit 1

shell_files=(install.sh wallpapers/generate.sh tests/check.sh tests/format.sh)
mapfile -t nix_files < <(find . -name "*.nix" \
    -not -path "./nixos/hardware-configuration.nix" \
    -not -path "./.git/*" | sort)
toml_files=(starship/starship.toml)

step() { printf '\e[34m── %s ──\e[0m\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

step "shfmt"
if have shfmt; then
    shfmt -w -i 4 -ci "${shell_files[@]}"
else
    echo "  (skip — install via 'nix develop')"
fi

step "nixpkgs-fmt"
if have nixpkgs-fmt; then
    nixpkgs-fmt "${nix_files[@]}"
else
    echo "  (skip)"
fi

step "taplo"
if have taplo; then
    taplo format "${toml_files[@]}"
else
    echo "  (skip)"
fi

echo "Done."
