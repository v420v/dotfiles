{ config, pkgs, lib, username ? "ibuki", ... }:

# Cross-platform home-manager config — shared by NixOS (home/ibuki.nix) and
# the M1 Macs (home/darwin.nix). Everything here must build on both
# x86_64-linux and aarch64-darwin, so no Hyprland/GTK/X11/Wayland bits live
# here — those are Linux-only and stay in home/ibuki.nix.
#
# `username` is threaded in from flake.nix — "ibuki" on the NixOS host and the
# personal Mac, "yoshida" on the work Mac. The `? "ibuki"` is just a fallback;
# every caller passes it explicitly (module-system arg defaults aren't honored).
{
  home.username = username;
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
    # (kitty itself: nix pkg on Linux/NixOS, Homebrew Cask on macOS — see
    #  home/ibuki.nix and darwin/configuration.nix. The kitty.conf symlink
    #  below is shared by both.)
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

  # ---------- direnv (per-directory env, fast nix-flake caching) ----------
  # Auto-loads a project's .envrc on cd. nix-direnv caches `use flake`, so dev
  # shells load instantly. Zsh integration is wired up automatically.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ---------- Zsh ----------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      # Suggest from history first, then fall back to the completion system so
      # even never-run commands get a ghosted hint. Accept with → or End.
      strategy = [ "history" "completion" ];
    };
    syntaxHighlighting.enable = true;
    # Up/Down arrows search history for whatever's already on the line.
    historySubstringSearch.enable = true;

    # fzf-tab: replaces zsh's completion menu with an fzf picker (+ previews).
    # Loads after compinit (home-manager orders this for us).
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
      zstyle ':completion:*' menu no                        # fzf-tab owns the menu
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*:descriptions' format '%F{cyan}── %d ──%f'
      zstyle ':completion:*:warnings'     format '%F{red}no matches%f'
      zstyle ':completion:*' group-name ''\'\'
      zstyle ':completion:*' verbose yes

      # fzf-tab: cycle result groups with < / >, preview dirs while completing.
      zstyle ':fzf-tab:*' switch-group '<' '>'
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=auto $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons=auto $realpath'

      # Modus Vivendi-friendly ls/eza colours (256-color ANSI indices)
      export LS_COLORS="di=38;5;75:ln=38;5;141:so=38;5;217:pi=38;5;223:ex=38;5;78:bd=38;5;215:cd=38;5;215:su=38;5;217:sg=38;5;217:tw=38;5;75:ow=38;5;75"

      # ─── Autosuggestions (faint inline ghost text) ───────────────
      # As you type, zsh-autosuggestions shows a dim prediction from history /
      # completion. Tune how faint it looks here. Accept it with → or End (whole
      # line), Ctrl-→ for just the next word, or Ctrl-Space.
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"
      bindkey '^ ' autosuggest-accept

      # ─── Keybinds ────────────────────────────────────────────────
      bindkey -e
      bindkey '^[[A'      history-substring-search-up
      bindkey '^[[B'      history-substring-search-down
      bindkey '^[OA'      history-substring-search-up    # app-cursor mode
      bindkey '^[OB'      history-substring-search-down
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
  # Symlinked into ~/.config so editing the repo is a live edit. These
  # (fastfetch, nvim, kitty.conf, starship.toml) are portable;
  # Hyprland/waybar/rofi/dunst symlinks are added in home/ibuki.nix
  # (Linux only).
  xdg.configFile = {
    # fastfetch/config.jsonc is platform-specific (the NixOS one hardcodes
    # nixos-logo.png via kitty-direct, which is wrong branding on macOS), so
    # it's symlinked per-file instead of the whole directory in one go.
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
