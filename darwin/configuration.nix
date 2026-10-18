{ pkgs, lib, inputs, username, ... }:

let
  manageNix = username != "yoshida";
in
{
  nix = lib.mkMerge [
    { enable = manageNix; }
    (lib.mkIf manageNix {
      settings.experimental-features = [ "nix-command" "flakes" ];
      # Pin `nixpkgs` in the flake registry and NIX_PATH to the exact nixpkgs
      # this flake is locked to, so `nix shell nixpkgs#foo` / `nix-shell -p foo`
      # reuse what is already in the store instead of fetching a channel.
      registry.nixpkgs.flake = inputs.nixpkgs;
      nixPath = [ "nixpkgs=flake:nixpkgs" ];
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
    mago

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
    awscli2
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
    ];
    casks = [
      # keep-sorted start
      "arc"
      "coteditor"
      "discord"
      "docker-desktop"
      "google-chrome"
      "kitty"
      "postman"
      "raycast"
      "zed"
      # keep-sorted end
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

    # Give Cmd+Space to input-source switching instead of Spotlight.
    #   64: Spotlight search        -> off
    #   60: previous input source   -> Cmd+Space (space=32, keycode=49, cmd=1048576)
    #   61: next input source       -> off (one toggle key is enough)
    CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
      "64".enabled = false;
      "60" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [ 32 49 1048576 ];
        };
      };
      "61".enabled = false;
    };
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
