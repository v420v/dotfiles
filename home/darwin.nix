{ config, pkgs, lib, username, ... }:

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

  # V is deliberately not a Nix package: it tracks master and updates itself
  # with `v up`, which needs a writable git checkout. Bootstrap it once here
  # (clone + make); after that Nix never touches it again.
  home.activation.bootstrapV = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    vroot="${config.xdg.dataHome}/v"
    if [ ! -x "$vroot/v" ]; then
      # make/cc come from the Xcode Command Line Tools in /usr/bin.
      export PATH="${pkgs.git}/bin:/usr/bin:/bin:$PATH"
      if [ ! -d "$vroot/.git" ]; then
        run git clone --depth 1 https://github.com/vlang/v "$vroot"
      fi
      run make -C "$vroot"
    fi
    run mkdir -p "$HOME/.local/bin"
    run ln -sfn "$vroot/v" "$HOME/.local/bin/v"
  '';

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
