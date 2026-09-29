{ config, pkgs, lib, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = "/home/ibuki";

  home.packages = with pkgs; [
    (claude-code.overrideAttrs (_: rec {
      version = "2.1.139";
      src = fetchurl {
        url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-x64/claude";
        hash = "sha256-wYAKCuUbWkx7M75qMtYrYWnZP2F0EZsu62iWzwzV1+Y=";
      };
    }))

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

    kitty

    firefox
    thunderbird
    file-roller

    bibata-cursors
    gnome-themes-extra
  ];

  programs.zsh.shellAliases = {
    rm = "rm -Iv";
    free = "free -h";
    rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles#nixos";
    edit-nix = "$EDITOR ~/dotfiles/nixos/configuration.nix";
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

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

  qt = {
    enable = true;
    platformTheme.name = "adwaita-dark";
    style.name = "adwaita-dark";
  };

  xdg.configFile = {
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hypr";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/waybar";
    "rofi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/rofi";
    "dunst".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dunst";
  };
}
