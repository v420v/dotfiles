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
  # Dev toolchains/LSPs/formatters also live here (not in home-manager) to
  # mirror the NixOS profile — gopls+gotools both ship /bin/modernize, so
  # the system buildEnv is the right place to tolerate the collision.
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget

    # Go: toolchain + LSP + formatters consumed by nvim (lspconfig + conform.nvim).
    # `go` itself is required: nvim-lspconfig's gopls root_dir resolver shells
    # out to `go env GOMODCACHE`, and a missing `go` crashes BufReadPost.
    go
    gopls
    gofumpt
    gotools
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
      # Launcher (binds cmd-Space by default, replacing Spotlight)
      "raycast"
      # Dev
      "zed"
      "postman"
      "docker-desktop"
    ];
  };

  # ---------- Window manager (yabai, BSP) ----------
  # Tiling window manager. Runs as a launchd user agent (nix-darwin handles
  # the plist). `enableScriptingAddition` requires SIP to be partially
  # disabled — leave it off and BSP tiling still works fully, just without
  # window-shadow/animation tweaks and a few focus niceties. To enable:
  # boot to recovery, `csrutil enable --without fs --without debug --without nvram`,
  # then flip the flag and rebuild.
  services.yabai = {
    enable = true;
    enableScriptingAddition = false;
    config = {
      layout = "bsp";
      window_placement = "second_child";
      top_padding = 8;
      bottom_padding = 8;
      left_padding = 8;
      right_padding = 8;
      window_gap = 8;
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_drop_action = "swap";
      focus_follows_mouse = "off";
      mouse_follows_focus = "off";
    };
  };

  # ---------- Hotkey daemon (skhd) ----------
  # Bindings live in skhd/skhdrc and are symlinked into ~/.config/skhd by
  # home/darwin.nix — live-editable, no rebuild needed for keymap changes.
  services.skhd.enable = true;

  # ---------- macOS system defaults ----------
  # Declarative `defaults write`. These change real macOS behaviour on the
  # next rebuild — tweak to taste. Dark mode keeps it in line with the
  # Modus Vivendi rice.
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false; # key repeat instead of accent menu
      KeyRepeat = 1; # fastest key repeat (15ms between repeats)
      InitialKeyRepeat = 10; # shortest delay before repeat (150ms)
      "com.apple.swipescrolldirection" = true; # enable natural scroll
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

    # Disable Spotlight's Cmd-Space (hotkey ID 64) so Raycast can bind it.
    # symbolichotkeys is cached by cfprefsd — needs a logout or reboot to apply.
    CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."64".enabled = false;
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
