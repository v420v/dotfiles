{ pkgs, lib, username, ... }:

# nix-darwin system configuration for the M1 MacBooks (personal + work).
# This is the macOS analogue of nixos/configuration.nix: it owns the
# system-level half (nix daemon settings, system packages, fonts, and the
# declarative `system.defaults` for macOS itself). The user-level half
# (shell, editor, CLI tools) is home/darwin.nix, attached as the
# home-manager module in flake.nix.
#
# Apply with: darwin-rebuild switch --flake ~/dotfiles#<username>
let
  # The work Mac (yoshida) runs Determinate Nix, which manages the Nix
  # installation with its own daemon and refuses to let nix-darwin manage it
  # too. On that host we hand Nix off: nix-darwin's `nix.*` options (gc,
  # optimise, settings) become unavailable, so they're only set when we own
  # the install. The personal Mac (ibuki) uses the nix-darwin-managed Nix.
  manageNix = username != "yoshida";

  # The work Mac is IT/MDM-managed: some GUI apps (Docker Desktop) are already
  # installed and locked down, so Homebrew can't adopt or modify them and
  # `brew bundle` aborts the whole rebuild. Keep those off the work cask list.
  isWork = username == "yoshida";
in
{
  # ---------- Nix daemon ----------
  nix = lib.mkMerge [
    { enable = manageNix; }
    (lib.mkIf manageNix {
      settings.experimental-features = [ "nix-command" "flakes" ];
      optimise.automatic = true;
      gc = {
        automatic = true;
        interval.Weekday = 0; # Sunday
        options = "--delete-older-than 14d";
      };
    })
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true; # claude-code is unfree (matches NixOS)

  # ---------- Primary user ----------
  # Required by nix-darwin for the user-scoped `system.defaults` below.
  # `username` is threaded in from flake.nix (ibuki on personal, yoshida on work).
  system.primaryUser = username;
  users.users.${username} = {
    home = "/Users/${username}";
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

    # PHP / Laravel: LSP (intelephense), the runtime + composer (each project's
    # own ./vendor/bin/pint, which conform.nvim prefers), and php-cs-fixer as
    # the system formatter fallback when a project doesn't vendor Pint.
    php
    php.packages.composer
    intelephense
    phpPackages.php-cs-fixer
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
      # "uninstall" removes Casks/Brews no longer listed here (keeps it
      # declarative) but leaves their app data intact. Use "zap" to also wipe
      # data, or "none" if you'd rather also `brew install` things by hand.
      cleanup = "uninstall";
    };
    # Non-GUI formulae that aren't in nixpkgs (or whose nixpkgs build is a
    # different project). `taps` pulls in the third-party formula repos they
    # live in.
    taps = [ "k1LoW/tap" ];
    brews = [
      # k1LoW/mo — Markdown viewer that opens .md files in the browser with
      # live-reload. nixpkgs `mo` is an unrelated Bash mustache tool, so it
      # comes from k1LoW's tap instead. Usage: `mo README.md`.
      "k1LoW/tap/mo"
      # MySQL 8.4 (LTS). Versioned, keg-only formula — not symlinked into the
      # Homebrew prefix, so add its bin to PATH (or use the full path) and start
      # it with `brew services start mysql@8.4`.
      "mysql@8.4"
    ];
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
      "coteditor"
      "postman"
      "docker-desktop"
      # Communication
      "discord"
    ];
  };

  # ---------- Window manager (yabai, BSP) ----------
  # Tiling window manager. Runs as a launchd user agent (nix-darwin handles
  # the plist). `enableScriptingAddition` requires SIP to be partially
  # disabled — leave it off and BSP tiling still works fully, just without
  # window-shadow/animation tweaks and a few focus niceties. To enable:
  # boot to recovery, `csrutil enable --without fs --without debug --without nvram`,
  # then flip the flag and rebuild.
  #
  # Personal Mac only — left off on the work Mac (stock macOS window mgmt).
  services.yabai = {
    enable = !isWork;
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
  # Personal Mac only — paired with yabai, so off on the work Mac too.
  services.skhd.enable = !isWork;

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
  #
  # `nix-env --delete-generations +6` trims each profile to the latest 7
  # generations (current + 6) on every rebuild. The weekly `nix.gc` above is
  # the time-based backstop that actually reclaims store paths; this just caps
  # the rollback list so it doesn't grow unboundedly. System profile is gated
  # on `manageNix` because the work Mac's Determinate Nix owns it.
  system.activationScripts.postActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true

    ${lib.optionalString manageNix ''
      nix-env --delete-generations +6 -p /nix/var/nix/profiles/system || true
    ''}
    sudo -u ${username} nix-env --delete-generations +6 -p /Users/${username}/.local/state/nix/profiles/profile || true
    sudo -u ${username} nix-env --delete-generations +6 -p /Users/${username}/.local/state/nix/profiles/home-manager || true
  '';

  # nix-darwin release series this config was written against. Don't change
  # casually — see `darwin-rebuild changelog`.
  system.stateVersion = 5;
}
