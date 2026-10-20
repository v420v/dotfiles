{ config, pkgs, username, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = "/Users/${username}";

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.packages = with pkgs; [
    coreutils-prefixed
    gnused

    pipes

    serie

    herdr

    mermaid-cli
  ];

  # mermaid-cli (puppeteer) has no bundled chromium on darwin; use the Homebrew cask Chrome
  home.sessionVariables.PUPPETEER_EXECUTABLE_PATH =
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";

  programs.zsh.shellAliases = {
    rm = "rm -iv";
    rebuild = "sudo darwin-rebuild switch --flake ~/dotfiles#${username}";
    rebuild-home = "home-manager switch --flake ~/dotfiles#${username}@mac";
    edit-nix = "$EDITOR ~/dotfiles/darwin/configuration.nix";
  };

  xdg.configFile = {
    "kitty/macos.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/kitty/macos.conf";
  };
}
