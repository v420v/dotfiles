#!/bin/bash

mkdir -p ~/.config/alacritty && ln -s ~/dotfiles/alacritty/alacritty.toml ~/.config/alacritty
mkdir -p ~/.config/nvim &&ln -s ~/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
