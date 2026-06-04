{ pkgs, ... }:

# nix-darwin system configuration for the M1 MacBook Air.
# This is the macOS analogue of nixos/configuration.nix: it owns the
# system-level half (nix daemon settings, system packages, fonts, and the
# declarative `system.defaults` for macOS itself). The user-level half
# (shell, editor, CLI tools) is home/darwin.nix, attached as the
# home-manager module in flake.nix.
#
# Apply with: darwin-rebuild switch --flake ~/dotfiles#mac
{
  # ---------- Nix daemon ----------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    interval.Weekday = 0; # Sunday
    options = "--delete-older-than 14d";
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true; # claude-code is unfree (matches NixOS)

  # ---------- Primary user ----------
  # Required by nix-darwin for the user-scoped `system.defaults` below.
  system.primaryUser = "ibuki";
  users.users.ibuki = {
    home = "/Users/ibuki";
    shell = pkgs.zsh;
  };

  # ---------- System-wide programs ----------
  # zsh enabled at the system level so /etc/zshrc sources the nix-darwin and
  # daemon profiles; the user-facing zsh config lives in home/darwin.nix.
  programs.zsh.enable = true;

  # Minimal system rescue tools (the rich CLI set is in home/darwin.nix).
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  # ---------- Fonts (system-wide, so kitty & friends can discover them) ----------
  fonts.packages = with pkgs; [
    nerd-fonts._0xproto
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # ---------- Homebrew (GUI apps) ----------
  # Homebrew itself is installed/managed by nix-homebrew (see flake.nix). GUI
  # apps don't package well via nixpkgs on darwin, so browsers/desktop apps come
  # from Casks declared here — `rebuild` runs `brew bundle` to converge them.
  # kitty is a Cask too (proper Spotlight/Dock .app); it still reads the
  # ~/.config/kitty/kitty.conf symlink that home/common.nix sets up.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # "uninstall" removes Casks no longer listed here (keeps it declarative)
      # but leaves their app data intact. Use "zap" to also wipe data, or
      # "none" if you'd rather also `brew install` things by hand.
      cleanup = "uninstall";
    };
    casks = [
      # Browsers
      "google-chrome"
      "arc"
      # Terminal
      "kitty"
      # Dev
      "zed"
      "postman"
      "docker-desktop"
    ];
  };

  # ---------- macOS system defaults ----------
  # Declarative `defaults write`. These change real macOS behaviour on the
  # next rebuild — tweak to taste. Dark mode keeps it in line with the
  # Modus Vivendi rice.
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false; # key repeat instead of accent menu
      KeyRepeat = 2; # fast key repeat
      InitialKeyRepeat = 15;
      "com.apple.swipescrolldirection" = false; # disable natural scroll
    };

    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false; # don't auto-rearrange Spaces
      tilesize = 48;
    };

    finder = {
      AppleShowAllFiles = true; # show hidden files
      FXPreferredViewStyle = "Nlsv"; # list view
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    trackpad.Clicking = true; # tap to click
  };

  # The keyboard remapping above (defaults) applies on rebuild; this makes the
  # current login session pick it up without a logout.
  system.activationScripts.postActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true
  '';

  # nix-darwin release series this config was written against. Don't change
  # casually — see `darwin-rebuild changelog`.
  system.stateVersion = 5;
}
