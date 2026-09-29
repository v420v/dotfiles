{ config, pkgs, lib, username ? "ibuki", ... }:

{
  home.username = username;
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neovim
    lazygit

    fastfetch
    btop
    ripgrep
    fd
    unzip
    p7zip
    ghq
    peco
    imagemagick
    ffmpeg
    qemu

    google-cloud-sdk

    bun

    wabt
    wasmtime

    mysql84
    sl
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
    BAT_THEME = "ansi";
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "v420v";
      email = "ibuki420v@gmail.com";
    };
    settings.alias = {
      lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
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
    fileWidget.command = "fd --type f --hidden --follow --exclude .git";
    changeDirWidget.command = "fd --type d --hidden --follow --exclude .git";
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
    enableZshIntegration = false;
    icons = "auto";
    git = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      strategy = [ "history" "completion" ];
    };
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

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

    shellAliases = {
      ls = "eza --group-directories-first --icons=auto";
      ll = "eza -lh --group-directories-first --icons=auto --git";
      la = "eza -lah --group-directories-first --icons=auto --git";
      lt = "eza --tree --level=2 --icons=auto";
      tree = "eza --tree --icons=auto";

      cat = "bat --paging=never --style=plain";
      less = "bat --paging=always";
      grep = "rg";
      top = "btop";
      vim = "nvim";
      vi = "nvim";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      mkdir = "mkdir -pv";
      cp = "cp -iv";
      mv = "mv -iv";
      df = "df -h";
      du = "du -h";

      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate --all";
      gp = "git pull";
      gP = "git push";
      gc = "git commit";
      ga = "git add";

      dots = "cd ~/dotfiles";
    };

    initContent = ''
      setopt HIST_REDUCE_BLANKS HIST_VERIFY INC_APPEND_HISTORY
      setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
      setopt INTERACTIVE_COMMENTS PROMPT_SUBST NO_BEEP

      zstyle ':completion:*' menu no
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*:descriptions' format '%F{cyan}── %d ──%f'
      zstyle ':completion:*:warnings'     format '%F{red}no matches%f'
      zstyle ':completion:*' group-name ''\'\'
      zstyle ':completion:*' verbose yes

      zstyle ':fzf-tab:*' switch-group '<' '>'
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=auto $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons=auto $realpath'

      export LS_COLORS="di=38;5;75:ln=38;5;141:so=38;5;217:pi=38;5;223:ex=38;5;78:bd=38;5;215:cd=38;5;215:su=38;5;217:sg=38;5;217:tw=38;5;75:ow=38;5;75"

      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"
      bindkey '^ ' autosuggest-accept

      bindkey -e
      bindkey '^[[A'      history-substring-search-up
      bindkey '^[[B'      history-substring-search-down
      bindkey '^[OA'      history-substring-search-up
      bindkey '^[OB'      history-substring-search-down
      bindkey '^[[1;5C'   forward-word
      bindkey '^[[1;5D'   backward-word
      bindkey '^[[3~'     delete-char
      bindkey '^[[H'      beginning-of-line
      bindkey '^[[F'      end-of-line

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

      if [[ -z "$ZSH_RICED_GREETED" && "$SHLVL" -le 1 ]]; then
        export ZSH_RICED_GREETED=1
        command -v fastfetch >/dev/null 2>&1 && fastfetch
      fi
    '';
  };

  home.file.".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/claude/settings.json";

  xdg.configFile = {
    "fastfetch/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink (
      "${config.home.homeDirectory}/dotfiles/fastfetch/"
      + (if pkgs.stdenv.isDarwin then "config-darwin.jsonc" else "config.jsonc")
    );
    "fastfetch/nixos-logo.png".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/fastfetch/nixos-logo.png";
    "fastfetch/nixos-logo.svg".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/fastfetch/nixos-logo.svg";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
    "kitty/kitty.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/kitty/kitty.conf";
    "starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/starship/starship.toml";
  };
}
