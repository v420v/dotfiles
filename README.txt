                           dotfiles

This repository contains dotfiles configuration for various tools
and applications.

Contents:
---------
- alacritty/     : Alacritty terminal emulator configuration
- nvim/          : Neovim editor configuration
- .gitconfig     : Git configuration file
- symlink.sh     : Script to create symbolic links

Setup:
------
Run the symlink.sh script to create symbolic links to your home directory:

    ./symlink.sh

This will create the necessary directories and symbolic links for:
- ~/.config/alacritty/alacritty.toml
- ~/.config/nvim/init.lua
- ~/.gitconfig

Note: Make sure the script has execute permissions:
    chmod +x symlink.sh
