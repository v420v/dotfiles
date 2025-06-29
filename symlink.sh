#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
  echo -e "${CYAN}==>${NC} $1"
}

success() {
  echo -e "${GREEN}✔${NC} $1"
}

log "creating config directories..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$CONFIG_DIR/nvim"
mkdir -p "$CONFIG_DIR/alacritty"

SYMLINKS=(
  #"$DOTFILES_DIR/.vimrc:$HOME/.vimrc"  # switched to neovim
  #"$DOTFILES_DIR/.vim:$HOME/.vim"
  "$DOTFILES_DIR/.config/nvim/init.lua:$CONFIG_DIR/nvim/init.lua"
  "$DOTFILES_DIR/.config/alacritty/alacritty.toml:$CONFIG_DIR/alacritty/alacritty.toml"
  "$DOTFILES_DIR/.gitconfig:$HOME/.gitconfig"
)

log "start creating symlinks..."
for pair in "${SYMLINKS[@]}"; do
  src="${pair%%:*}"
  dest="${pair##*:}"
  ln -sf "$src" "$dest"
  success "linked $dest → $src"
done

log "${GREEN}all symlinks created successfully${NC}"

