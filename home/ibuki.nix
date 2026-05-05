{ config, pkgs, lib, ... }:

{
  home.username = "ibuki";
  home.homeDirectory = "/home/ibuki";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # ---------- User packages ----------
  # Dev toolchains, LSPs, and formatters live in environment.systemPackages.
  # Several of them (gcc/clang, gopls/gotools, ...) ship overlapping binaries
  # like /bin/cpp or /bin/modernize, and only NixOS' system buildEnv tolerates
  # those collisions — HM's user profile rejects them outright.
  home.packages = with pkgs; [
    # Editor + lightweight wrappers
    neovim
    lazygit
    claude-code

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
    networkmanagerapplet

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

    # Apps
    firefox
    thunderbird
    file-roller

    # Qt theming: qt5ct/qt6ct as the platform theme (color scheme, fonts),
    # Kvantum as the widget style, Catppuccin-Mocha-Mauve as the Kvantum theme.
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
    (catppuccin-kvantum.override {
      accent = "mauve";
      variant = "mocha";
    })
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
      "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
      "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
      "--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
      "--color=selected-bg:#45475a"
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

  # ---------- Cursor (single source of truth for X11 / Wayland / GTK) ----------
  home.pointerCursor = {
    name = "catppuccin-mocha-mauve-cursors";
    package = pkgs.catppuccin-cursors.mochaMauve;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # ---------- GTK 2/3/4 ----------
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-mauve-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "mocha";
        size = "standard";
      };
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
  # qt5ct/qt6ct as platform theme (palette + fonts), Kvantum as widget
  # style, Catppuccin-Mocha-Mauve as the Kvantum theme. HM writes
  # Style=kvantum into qt5ct.conf / qt6ct.conf automatically.
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  # Tell Kvantum which theme to load (no native HM option for this).
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=catppuccin-mocha-mauve
  '';

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

      # fs
      mkdir = "mkdir -pv";
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -Iv";
      df = "df -h";
      du = "du -h";
      free = "free -h";

      # git
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate --all";
      gp = "git pull";
      gP = "git push";
      gc = "git commit";
      ga = "git add";

      # nix
      rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles#nixos";
      edit-nix = "$EDITOR ~/dotfiles/nixos/configuration.nix";
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

      # Catppuccin-flavoured ls/eza colours
      export LS_COLORS="di=38;5;111:ln=38;5;176:so=38;5;217:pi=38;5;223:ex=38;5;150:bd=38;5;215:cd=38;5;215:su=38;5;217:sg=38;5;217:tw=38;5;111:ow=38;5;111"

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
  # Symlinked into ~/.config so editing the repo is a live edit.
  xdg.configFile = {
    "hypr".source       = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hypr";
    "waybar".source     = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/waybar";
    "rofi".source       = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/rofi";
    "dunst".source      = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dunst";
    "fastfetch".source  = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/fastfetch";
    "nvim".source       = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
    "kitty/kitty.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/kitty/kitty.conf";
  };
}
