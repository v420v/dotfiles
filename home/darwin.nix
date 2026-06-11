{ config, pkgs, lib, username, ... }:

# macOS (Apple Silicon / aarch64-darwin) home-manager profile, used standalone
# via `home-manager switch --flake ~/dotfiles#<username>@mac` — no nix-darwin and
# no system-level changes required, just the Nix package manager. `username` is
# threaded in from flake.nix (ibuki on personal, yoshida on work).
#
# Imports the cross-platform base from common.nix; everything Hyprland/GTK/X11
# stays in home/ibuki.nix and never reaches the Mac. Add Mac-only desktop apps
# here (or install GUI apps via Homebrew alongside this — the two coexist).
{
  imports = [ ./common.nix ];

  home.homeDirectory = "/Users/${username}";

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

    # Animated pipes terminal screensaver (pipeseroni/pipes.sh).
    pipes
  ];

  # ---------- macOS-only shell aliases ----------
  # BSD `rm` has no `-I`; `-i` is the closest portable equivalent. There's no
  # `free`. `rebuild` runs nix-darwin (system + user); `rebuild-home` is the
  # standalone home-manager fallback for user-only changes without sudo.
  programs.zsh.shellAliases = {
    rm = "rm -iv";
    rebuild = "sudo darwin-rebuild switch --flake ~/dotfiles#${username}";
    rebuild-home = "home-manager switch --flake ~/dotfiles#${username}@mac";
    edit-nix = "$EDITOR ~/dotfiles/darwin/configuration.nix";
  };

  # ---------- macOS-only config symlinks ----------
  # skhd is a Mac-only hotkey daemon, so its rc lives here (not common.nix).
  # Symlinked out-of-store: edit skhd/skhdrc in the repo and it's live after
  # `skhd --reload` (or auto-picked-up on file save). Personal Mac only —
  # skhd/yabai aren't enabled on the work Mac, so the rc is skipped there.
  xdg.configFile = lib.mkMerge [
    {
      # macOS-only kitty overrides (native title bar, etc). kitty.conf pulls
      # this in via `globinclude`; the symlink only exists on macOS, so Linux
      # skips it. Applies to both Macs (personal + work).
      "kitty/macos.conf".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/kitty/macos.conf";
    }
    (lib.mkIf (username != "yoshida") {
      "skhd/skhdrc".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/skhd/skhdrc";
    })
  ];
}
