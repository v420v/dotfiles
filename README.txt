                           dotfiles

This repository contains dotfiles configuration for various tools
and applications.

Contents:
---------
- alacritty/     : Alacritty terminal emulator configuration
- wezterm/       : WezTerm terminal emulator configuration
- nvim/          : Neovim editor configuration
- zsh/           : Zsh shell configuration (aliases)
- git/           : Git configuration files
- .zshrc         : Zsh shell configuration
- symlink.sh     : Script to create symbolic links

Setup:
------
Run the symlink.sh script to create symbolic links to your home directory:

    ./symlink.sh

This will create the necessary directories and symbolic links for:
- ~/.config/alacritty/alacritty.toml
- ~/.config/wezterm/wezterm.lua
- ~/.config/nvim/init.lua
- ~/.config/git/ignore
- ~/.gitconfig
- ~/.zshrc
- ~/.zsh_aliases

Note: Make sure the script has execute permissions:
    chmod +x symlink.sh

MacOS
- Stop macOS from automatically creating .DS_Store files
    defaults write com.apple.desktopservices DSDontWriteNetworkStores true
- Set KyeRepeast Speed
    defaults write NSGlobalDomain KeyRepeat -int 1
- Cursor 
    osascript -e 'id of app "Cursor.app"'
    defaults write {domain name} ApplePressAndHoldEnabled -bool false
- Show dotfiles on Finder
    defaults write com.apple.finder AppleShowAllFiles ON

