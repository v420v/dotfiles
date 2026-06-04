{ config, pkgs, lib, ... }:

# NixOS / Linux home-manager profile. Imports the cross-platform base from
# common.nix and layers on everything that only makes sense on the Hyprland
# desktop (the WM ecosystem, GTK/Qt theming, X11/Wayland cursor, the pinned
# Linux claude-code binary, and the desktop config symlinks).
#
# The Mac equivalent is home/darwin.nix (also imports common.nix).
{
  imports = [ ./common.nix ];

  home.homeDirectory = "/home/ibuki";

  # ---------- Linux-only user packages ----------
  # Dev toolchains, LSPs, and formatters live in environment.systemPackages.
  # Several of them (gcc/clang, gopls/gotools, ...) ship overlapping binaries
  # like /bin/cpp or /bin/modernize, and only NixOS' system buildEnv tolerates
  # those collisions — HM's user profile rejects them outright.
  home.packages = with pkgs; [
    # Pinned: nixpkgs skipped 2.1.139 (went 2.1.138 -> 2.1.140), so we
    # fetch the upstream binary directly. Linux x86_64 only.
    (claude-code.overrideAttrs (_: rec {
      version = "2.1.139";
      src = fetchurl {
        url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-x64/claude";
        hash = "sha256-wYAKCuUbWkx7M75qMtYrYWnZP2F0EZsu62iWzwzV1+Y=";
      };
    }))

    # Hyprland ecosystem (user-side helpers)
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
    impala

    # Terminal (macOS gets kitty from a Homebrew Cask instead; see
    # darwin/configuration.nix)
    kitty

    # Apps
    firefox
    thunderbird
    file-roller

    # Cursor + GTK theme packages for the Modus Vivendi rice.
    bibata-cursors
    gnome-themes-extra
  ];

  # ---------- Linux-only shell aliases ----------
  # `rm -Iv` (GNU "prompt once") + `free` only exist in the GNU userland.
  # nixos-rebuild lives here; the Mac uses `home-manager switch` instead.
  programs.zsh.shellAliases = {
    rm = "rm -Iv";
    free = "free -h";
    rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles#nixos";
    edit-nix = "$EDITOR ~/dotfiles/nixos/configuration.nix";
  };

  # ---------- Cursor (single source of truth for X11 / Wayland / GTK) ----------
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # ---------- GTK 2/3/4 ----------
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "0xProto Nerd Font";
      size = 11;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # ---------- Qt ----------
  # Adwaita-dark as both platform theme and widget style. Drops the Kvantum
  # stack entirely — matches the Modus Vivendi "no chrome" aesthetic. HM pulls
  # in adwaita-qt / adwaita-qt6 automatically.
  qt = {
    enable = true;
    platformTheme.name = "adwaita-dark";
    style.name = "adwaita-dark";
  };

  # ---------- Linux-only config symlinks ----------
  # common.nix already symlinks fastfetch / nvim / kitty; these are the
  # Hyprland-desktop configs that don't exist on the Mac.
  xdg.configFile = {
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hypr";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/waybar";
    "rofi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/rofi";
    "dunst".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dunst";
  };
}
