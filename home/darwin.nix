{ pkgs, ... }:

# macOS (Apple Silicon / aarch64-darwin) home-manager profile, used standalone
# via `home-manager switch --flake ~/dotfiles#ibuki@mac` — no nix-darwin and no
# system-level changes required, just the Nix package manager.
#
# Imports the cross-platform base from common.nix; everything Hyprland/GTK/X11
# stays in home/ibuki.nix and never reaches the Mac. Add Mac-only desktop apps
# here (or install GUI apps via Homebrew alongside this — the two coexist).
{
  imports = [ ./common.nix ];

  home.homeDirectory = "/Users/ibuki";

  # ---------- macOS-only user packages ----------
  home.packages = with pkgs; [
    # On the Mac, Claude Code comes straight from nixpkgs (the Linux profile
    # pins a specific build via a fetchurl override; that URL is linux-x64
    # only, so we just take the packaged aarch64-darwin build here).
    claude-code

    # GNU coreutils, so the shared GNU-style aliases/flags behave the same as
    # on NixOS. Exposed g-prefixed (gls, gsed, ...) to avoid shadowing the BSD
    # tools macOS itself depends on.
    coreutils
  ];

  # ---------- macOS-only shell aliases ----------
  # BSD `rm` has no `-I`; `-i` is the closest portable equivalent. There's no
  # `free`. `rebuild` runs nix-darwin (system + user); `rebuild-home` is the
  # standalone home-manager fallback for user-only changes without sudo.
  programs.zsh.shellAliases = {
    rm = "rm -iv";
    rebuild = "sudo darwin-rebuild switch --flake ~/dotfiles#mac";
    rebuild-home = "home-manager switch --flake ~/dotfiles#ibuki@mac";
    edit-nix = "$EDITOR ~/dotfiles/darwin/configuration.nix";
  };
}
