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
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  # ---------- Display manager: greetd + tuigreet ----------
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # ---------- Hyprland ----------
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
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

  # ---------- Fonts ----------
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

  # ---------- Programs ----------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 100000;
  };

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs; [ thunar-archive-plugin thunar-volman ];

  # GTK theme support service
  programs.dconf.enable = true;

  # ---------- System packages ----------
  environment.systemPackages = with pkgs; [
    # Core
    vim
    neovim
    wget
    curl
    git
    lazygit
    nodejs_20
    claude-code

    # Toolchains for low-level work
    gcc
    clang
    gnumake
    cmake
    gdb
    nasm

    # Language servers (consumed by nvim-lspconfig — no Mason on Nix)
    gopls                          # Go
    clang-tools                    # clangd, clang-format
    typescript-language-server
    vscode-langservers-extracted   # html / css / json / eslint
    asm-lsp                        # x86 / ARM / RISC-V assembly hover
    lua-language-server
    bash-language-server
    nil                            # Nix LSP

    # Formatters
    gofumpt
    gotools                        # goimports
    prettierd
    stylua
    nixpkgs-fmt
    shfmt

    # Hyprland ecosystem
    waybar
    hyprpaper
    hyprlock
    hypridle
    hyprshot
    rofi
    dunst
    libnotify
    wl-clipboard
    cliphist
    grim
    slurp
    swappy
    brightnessctl
    pamixer
    pavucontrol
    playerctl
    networkmanagerapplet
    polkit_gnome

    # Terminal & shell
    kitty
    starship
    fastfetch
    btop
    fzf
    ripgrep
    fd
    bat
    eza
    zoxide
    unzip
    p7zip
    ghq
    peco

    # Apps
    firefox
    thunderbird
    file-roller

    # Theming
    catppuccin-gtk
    catppuccin-cursors.mochaMauve
    papirus-icon-theme

    # Misc
    xdg-utils
    gsettings-desktop-schemas
    gnome-themes-extra
    imagemagick
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
