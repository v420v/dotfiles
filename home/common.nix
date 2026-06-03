{ config, pkgs, lib, ... }:

# Cross-platform home-manager config — shared by NixOS (home/ibuki.nix) and
# the M1 Mac (home/darwin.nix). Everything here must build on both
# x86_64-linux and aarch64-darwin, so no Hyprland/GTK/X11/Wayland bits live
# here — those are Linux-only and stay in home/ibuki.nix.
{
  home.username = "ibuki";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # ---------- User packages (portable CLI tooling) ----------
  # Desktop apps and the Hyprland ecosystem are Linux-only and live in
  # home/ibuki.nix; this list is everything that makes sense on both hosts.
  home.packages = with pkgs; [
    # Editor + git helpers
    neovim
    lazygit

    # Terminal companions
    kitty
    fastfetch
    btop
    ripgrep
    fd
    unzip
    p7zip
    ghq
    peco
    imagemagick
  ];

  # ---------- Session-wide env ----------
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
    BAT_THEME = "ansi";
  };

  # ---------- Native HM modules ----------
  programs.git = {
    enable = true;
    settings.user = {
      name = "v420v";
      email = "ibuki420v@gmail.com";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$directory$git_branch$git_status$character";
      add_newline = false;

      directory = {
        style = "blue";
        format = "[$path]($style) ";
        truncation_length = 3;
        truncation_symbol = "…/";
        home_symbol = "~";
      };

      git_branch = {
        symbol = "";
        style = "purple";
        format = "[$branch]($style) ";
      };

      git_status = {
        style = "yellow";
        format = "[$all_status$ahead_behind]($style) ";
      };

      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](purple)";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--color=bg+:#1e1e1e,bg:#000000,spinner:#fec43f,hl:#ff5f59"
      "--color=fg:#ffffff,header:#ff5f59,info:#b6a0ff,pointer:#fec43f"
      "--color=marker:#79a8ff,fg+:#ffffff,prompt:#b6a0ff,hl+:#ff5f59"
      "--color=selected-bg:#2b2b2b"
      "--height=40%"
      "--layout=reverse"
      "--border=rounded"
      "--prompt=❯ "
      "--pointer=▶"
      "--marker=✚"
    ];
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };

  programs.bat = {
    enable = true;
    config.theme = "ansi";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd" "cd" ];
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = false; # we set the aliases ourselves below
    icons = "auto";
    git = true;
  };

  # ---------- Zsh ----------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 100000;
      save = 100000;
      path = "$HOME/.zsh_history";
      extended = true;
      share = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
    };

    # Portable aliases only. `rm`/`free`/`rebuild`/`edit-nix` differ between
    # GNU (NixOS) and BSD (macOS) userlands, so each host file adds its own.
    shellAliases = {
      # eza
      ls = "eza --group-directories-first --icons=auto";
      ll = "eza -lh --group-directories-first --icons=auto --git";
      la = "eza -lah --group-directories-first --icons=auto --git";
      lt = "eza --tree --level=2 --icons=auto";
      tree = "eza --tree --icons=auto";

      # bat / rg / btop / nvim
      cat = "bat --paging=never --style=plain";
      less = "bat --paging=always";
      grep = "rg";
      top = "btop";
      vim = "nvim";
      v = "nvim";
      vi = "nvim";

      # nav
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # fs (flags below are common to GNU and BSD coreutils)
      mkdir = "mkdir -pv";
      cp = "cp -iv";
      mv = "mv -iv";
      df = "df -h";
      du = "du -h";

      # git
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate --all";
      gp = "git pull";
      gP = "git push";
      gc = "git commit";
      ga = "git add";

      # nav to repo
      dots = "cd ~/dotfiles";
    };

    initContent = ''
      # ─── Behaviour ───────────────────────────────────────────────
      setopt HIST_REDUCE_BLANKS HIST_VERIFY INC_APPEND_HISTORY
      setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
      setopt INTERACTIVE_COMMENTS PROMPT_SUBST NO_BEEP

      # ─── Completion polish ───────────────────────────────────────
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*:descriptions' format '%F{cyan}── %d ──%f'
      zstyle ':completion:*:warnings'     format '%F{red}no matches%f'
      zstyle ':completion:*' group-name ''\'\'
      zstyle ':completion:*' verbose yes

      # Modus Vivendi-friendly ls/eza colours (256-color ANSI indices)
      export LS_COLORS="di=38;5;75:ln=38;5;141:so=38;5;217:pi=38;5;223:ex=38;5;78:bd=38;5;215:cd=38;5;215:su=38;5;217:sg=38;5;217:tw=38;5;75:ow=38;5;75"

      # ─── Keybinds ────────────────────────────────────────────────
      bindkey -e
      bindkey '^[[A'      history-search-backward
      bindkey '^[[B'      history-search-forward
      bindkey '^[[1;5C'   forward-word
      bindkey '^[[1;5D'   backward-word
      bindkey '^[[3~'     delete-char
      bindkey '^[[H'      beginning-of-line
      bindkey '^[[F'      end-of-line

      # ghq + peco — Ctrl-G to fuzzy-jump into any cloned repo
      if command -v ghq >/dev/null 2>&1 && command -v peco >/dev/null 2>&1; then
        peco-ghq-src() {
          local src
          src=$(ghq list --full-path | peco --query "$LBUFFER")
          if [[ -n $src ]]; then
            BUFFER="cd ''${(q)src}"
            zle accept-line
          fi
          zle reset-prompt
        }
        zle -N peco-ghq-src
        bindkey '^G' peco-ghq-src
      fi

      # ─── Greeter ─────────────────────────────────────────────────
      # fastfetch only on first interactive login; nested shells stay clean.
      if [[ -o login && -z "$ZSH_RICED_GREETED" ]]; then
        export ZSH_RICED_GREETED=1
        command -v fastfetch >/dev/null 2>&1 && fastfetch
      fi
    '';
  };

  # ---------- Dotfiles that stay as plain config files ----------
  # Symlinked into ~/.config so editing the repo is a live edit. These three
  # are portable; Hyprland/waybar/rofi/dunst symlinks are added in
  # home/ibuki.nix (Linux only).
  xdg.configFile = {
    "fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/fastfetch";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
    "kitty/kitty.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/kitty/kitty.conf";
  };
}
