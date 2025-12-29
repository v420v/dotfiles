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

# Only create bash_aliases symlink if bash is the shell
case "$SHELL" in
  *bash*)
    if [ ! -L ~/.bash_aliases ]; then
      ln -s ~/dotfiles/.bash_aliases ~/.bash_aliases
    fi
    ;;
esac
