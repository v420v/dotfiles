#!/bin/bash

mkdir -p ~/.config/alacritty && ln -s ~/dotfiles/alacritty/alacritty.toml ~/.config/alacritty
mkdir -p ~/.config/nvim &&ln -s ~/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
ln -s ~/dotfiles/.gitconfig ~/.gitconfig

# Only create bash_aliases symlink if bash is the shell
if [[ "$SHELL" == *"bash"* ]]; then
  ln -s ~/dotfiles/.bash_aliases ~/.bash_aliases
fi
