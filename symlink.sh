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
  ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig
fi

# git ignore
mkdir -p ~/.config/git
if [ ! -L ~/.config/git/ingore ]; then
  ln -s ~/dotfiles/git/ignore ~/.config/git/ignore
fi

# aliases
if [ ! -L ~/.zsh_aliases ]; then
  ln -s ~/dotfiles/zsh/.zsh_aliases ~/.zsh_aliases
fi

# .zshrc
if [ ! -L ~/.zshrc ]; then
  ln -s ~/dotfiles/.zshrc ~/.zshrc
fi


