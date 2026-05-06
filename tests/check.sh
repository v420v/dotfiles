#!/usr/bin/env bash
# Lint + parse every config in this rice.
#
# Inside `nix develop` every tool is on PATH; outside it, missing tools
# are skipped with a warning so the script stays useful on a bare shell.

set -uo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
cd "$ROOT" || exit 1

if [ -t 1 ]; then
    R=$'\e[31m'
    G=$'\e[32m'
    Y=$'\e[33m'
    B=$'\e[34m'
    D=$'\e[2m'
    X=$'\e[0m'
else
    R=''
    G=''
    Y=''
    B=''
    D=''
    X=''
fi

fail=0
skipped=()

section() { printf "\n%s── %s ──%s\n" "$B" "$1" "$X"; }
have() { command -v "$1" >/dev/null 2>&1; }
ok() { printf "  %s✓%s %s\n" "$G" "$X" "$1"; }
bad() {
    printf "  %s✗%s %s\n" "$R" "$X" "$1"
    fail=1
}
skip() {
    printf "  %s∼ skip%s %s %s(install via 'nix develop')%s\n" "$D" "$X" "$1" "$D" "$X"
    skipped+=("$1")
}

run() {
    local label="$1"
    shift
    local out
    if out=$("$@" 2>&1); then
        ok "$label"
    else
        bad "$label"
        printf '%s\n' "$out" | sed 's/^/      /'
    fi
}

# ───── Shell ─────
section "Shell"
shell_files=(install.sh wallpapers/generate.sh tests/check.sh tests/format.sh)

for f in "${shell_files[@]}"; do
    run "bash -n  $f" bash -n "$f"
done

if have shellcheck; then
    run "shellcheck" shellcheck "${shell_files[@]}"
else
    skip "shellcheck"
fi

if have shfmt; then
    run "shfmt -d (4-space, indent-case)" shfmt -d -i 4 -ci "${shell_files[@]}"
else
    skip "shfmt"
fi

# ───── Nix ─────
section "Nix"
mapfile -t nix_files < <(find . -name "*.nix" \
    -not -path "./nixos/hardware-configuration.nix" \
    -not -path "./.git/*" | sort)

for f in "${nix_files[@]}"; do
    run "nix-instantiate --parse $f" nix-instantiate --parse "$f"
done

if have nixpkgs-fmt; then
    run "nixpkgs-fmt --check" nixpkgs-fmt --check "${nix_files[@]}"
else
    skip "nixpkgs-fmt"
fi

if have statix; then
    # See .statix.toml for disabled rules and ignored paths.
    run "statix check" statix check .
else
    skip "statix"
fi

if have deadnix; then
    # --no-lambda-pattern-names keeps conventional `{ config, pkgs, lib, ... }`
    # headers; --no-lambda-arg keeps unused single args (e.g. flake `self`).
    run "deadnix" deadnix --no-lambda-arg --no-lambda-pattern-names --fail "${nix_files[@]}"
else
    skip "deadnix"
fi

# ───── Lua ─────
section "Lua"
mapfile -t lua_files < <(find nvim -name "*.lua" | sort)

if have luac; then
    for f in "${lua_files[@]}"; do
        run "luac -p $f" luac -p "$f"
    done
else
    skip "luac"
fi

# ───── TOML ─────
section "TOML"
toml_files=(starship/starship.toml)

if have taplo; then
    run "taplo format --check" taplo format --check "${toml_files[@]}"
    run "taplo lint" taplo lint "${toml_files[@]}"
else
    skip "taplo"
fi

# ───── JSON ─────
section "JSON"
json_files=(nvim/lazy-lock.json flake.lock)

if have jq; then
    for f in "${json_files[@]}"; do
        run "jq . $f" jq -e . "$f"
    done
else
    skip "jq"
fi

echo
if [ "${#skipped[@]}" -gt 0 ]; then
    printf "%sskipped (tool missing):%s %s\n" "$Y" "$X" "${skipped[*]}"
fi
if [ "$fail" -ne 0 ]; then
    printf "%sFAILED%s\n" "$R" "$X"
    exit 1
fi
printf "%sOK%s\n" "$G" "$X"
