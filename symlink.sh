#!/bin/bash

# alacritty
mkdir -p ~/.config/alacritty
if [ ! -L ~/.config/alacritty/alacritty.toml ]; then
  ln -s ~/dotfiles/alacritty/alacritty.toml ~/.config/alacritty
fi

# nvim
mkdir -p ~/.config/nvim 
if [ ! -L ~/.config/nvim/init.lua ]; then
ln -s ~/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
fi

# gitconfig
if [ ! -L ~/.gitconfig ]; then
  ln -s ~/dotfiles/.gitconfig ~/.gitconfig
fi

# ZSH
case "$SHELL" in
  *zsh*)
    if [ ! -L ~/.zsh_aliases ]; then
      ln -s ~/dotfiles/zsh/.zsh_aliases ~/.zsh_aliases
    fi
    ;;
esac
