{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # ---------- Boot ----------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ---------- Networking ----------
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ---------- Locale / Time ----------
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  # ---------- Keymap ----------
  services.xserver.xkb = {
    layout = "jp";
    variant = "OADG109A";
  };
  console.keyMap = "jp106";

  # ---------- Japanese input (fcitx5 + mozc) ----------
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc fcitx5-gtk ];
  };

  # ---------- User ----------
  users.users.ibuki = {
    isNormalUser = true;
    description = "ibuki";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  # ---------- Display manager: greetd + tuigreet ----------
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start -- hyprland-uwsm.desktop'";
        user = "greeter";
      };
    };
  };

  # ---------- Hyprland ----------
  # withUWSM wraps Hyprland in Universal Wayland Session Manager so
  # graphical-session.target activates properly and the env reaches dbus —
  # required to silence Hyprland's "started without start-hyprland" warning.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # XDG portals (file pickers, screenshare)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ---------- Audio: PipeWire ----------
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ---------- Bluetooth ----------
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # ---------- Printing ----------
  services.printing.enable = true;

  # ---------- Fonts (system-wide so all apps can discover them) ----------
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts._0xproto
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    font-awesome
  ];

  # ---------- System-level program enablement ----------
  # zsh must be enabled at the system level so it's a registered login shell.
  # User-facing zsh configuration (plugins, history, aliases) lives in
  # home-manager (home/ibuki.nix).
  programs.zsh.enable = true;

  # Thunar wires up gvfs / tumbler at the system level.
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs; [ thunar-archive-plugin thunar-volman ];

  # GTK theme support service
  programs.dconf.enable = true;

  # ---------- System packages ----------
  # Dev toolchains/LSPs/formatters live here (not in home-manager) because
  # several of them ship overlapping binaries (gcc+clang both have /bin/cpp,
  # gopls+gotools both have /bin/modernize, etc.) and NixOS' system buildEnv
  # is the only profile that tolerates those collisions.
  environment.systemPackages = with pkgs; [
    # Always-available rescue tools (also useful as root)
    vim
    wget
    curl
    git

    # Compilers / build tools
    gcc
    clang
    gnumake
    cmake
    gdb
    nasm
    nodejs_20

    # Language servers (consumed by nvim-lspconfig from $PATH)
    gopls
    clang-tools
    typescript-language-server
    vscode-langservers-extracted
    asm-lsp
    lua-language-server
    bash-language-server
    nil

    # Formatters
    gofumpt
    gotools
    prettierd
    stylua
    nixpkgs-fmt
    shfmt

    # GTK/portal plumbing referenced by user apps
    xdg-utils
    gsettings-desktop-schemas
    gnome-themes-extra

    # Polkit GUI agent (referenced by the systemd user service below)
    polkit_gnome
  ];

  # Allow polkit agent to run for GUI auth prompts
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # ---------- Nix settings ----------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # ---------- Firewall ----------
  networking.firewall.enable = true;

  system.stateVersion = "24.11";
}
