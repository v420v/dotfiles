{ pkgs, lib, username, ... }:

let
  manageNix = username != "yoshida";
in
{
  nix = lib.mkMerge [
    { enable = manageNix; }
    (lib.mkIf manageNix {
      settings.experimental-features = [ "nix-command" "flakes" ];
      optimise.automatic = true;
      gc = {
        automatic = true;
        interval.Weekday = 0;
        options = "--delete-older-than 14d";
      };
    })
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  system.primaryUser = username;
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget

    go
    gopls
    gofumpt
    gotools

    php
    php.packages.composer
    intelephense
    phpPackages.php-cs-fixer

    nodejs

    uv

    vlang

    clang-tools
    typescript-language-server
    vscode-langservers-extracted
    asm-lsp
    lua-language-server
    bash-language-server
    nil

    prettierd
    stylua
    nixpkgs-fmt
    shfmt
  ];

  fonts.packages = with pkgs; [
    nerd-fonts._0xproto
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
    taps = [ "k1LoW/tap" ];
    brews = [
      "k1LoW/tap/mo"
      "mysql@8.4"
    ];
    casks = [
      "google-chrome"
      "arc"
      "kitty"
      "raycast"
      "zed"
      "coteditor"
      "postman"
      "docker-desktop"
      "discord"
    ];
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 1;
      InitialKeyRepeat = 10;
      "com.apple.swipescrolldirection" = true;
    };

    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false;
      tilesize = 48;
    };

    finder = {
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    trackpad.Clicking = true;

    CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."64".enabled = false;
  };

  system.activationScripts.postActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true

    ${lib.optionalString manageNix ''
      nix-env --delete-generations +6 -p /nix/var/nix/profiles/system || true
    ''}
    sudo -u ${username} nix-env --delete-generations +6 -p /Users/${username}/.local/state/nix/profiles/profile || true
    sudo -u ${username} nix-env --delete-generations +6 -p /Users/${username}/.local/state/nix/profiles/home-manager || true
  '';

  system.stateVersion = 5;
}
