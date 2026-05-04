# ─── ZSH ── Catppuccin Mocha rice ─────────────────────────────
# NixOS sources /etc/zshrc which already handles compinit,
# zsh-autosuggestions, and zsh-syntax-highlighting when
# programs.zsh.{enableCompletion,autosuggestions,syntaxHighlighting}
# are toggled on. Keep this file focused on user-facing tweaks.

# ─── History ─────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY        # timestamp entries
setopt SHARE_HISTORY           # share between live shells
setopt HIST_IGNORE_DUPS        # drop consecutive dupes
setopt HIST_IGNORE_ALL_DUPS    # drop older dupes when a new one is added
setopt HIST_IGNORE_SPACE       # leading-space commands skip history
setopt HIST_REDUCE_BLANKS      # tidy whitespace
setopt HIST_VERIFY             # don't auto-execute on !! recall
setopt INC_APPEND_HISTORY      # write as you go

# ─── Behaviour ───────────────────────────────────────────────
setopt AUTO_CD                 # `..` to go up, bare dirs cd into them
setopt AUTO_PUSHD              # cd builds a directory stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt INTERACTIVE_COMMENTS    # # comments in interactive shells
setopt PROMPT_SUBST
setopt NO_BEEP

# ─── Completion polish ───────────────────────────────────────
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{cyan}── %d ──%f'
zstyle ':completion:*:warnings'     format '%F{red}no matches%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Catppuccin-flavoured ls/eza colours
export LS_COLORS="di=38;5;111:ln=38;5;176:so=38;5;217:pi=38;5;223:ex=38;5;150:bd=38;5;215:cd=38;5;215:su=38;5;217:sg=38;5;217:tw=38;5;111:ow=38;5;111"

# ─── Keybinds ────────────────────────────────────────────────
bindkey -e                         # emacs-style line editing
bindkey '^[[A'      history-search-backward   # ↑ search by prefix
bindkey '^[[B'      history-search-forward    # ↓ search by prefix
bindkey '^[[1;5C'   forward-word              # Ctrl→
bindkey '^[[1;5D'   backward-word             # Ctrl←
bindkey '^[[3~'     delete-char               # Del
bindkey '^[[H'      beginning-of-line         # Home
bindkey '^[[F'      end-of-line               # End

# ─── Aliases ─────────────────────────────────────────────────
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lh --group-directories-first --icons=auto --git'
  alias la='eza -lah --group-directories-first --icons=auto --git'
  alias lt='eza --tree --level=2 --icons=auto'
  alias tree='eza --tree --icons=auto'
else
  alias ll='ls -lh'
  alias la='ls -lah'
fi

command -v bat   >/dev/null 2>&1 && alias cat='bat --paging=never --style=plain'
command -v bat   >/dev/null 2>&1 && alias less='bat --paging=always'
command -v rg    >/dev/null 2>&1 && alias grep='rg'
command -v btop  >/dev/null 2>&1 && alias top='btop'
command -v nvim  >/dev/null 2>&1 && alias vim='nvim' && alias v='nvim' && alias vi='nvim'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias gs='git status'
alias gd='git diff'
alias gl="git log --oneline --graph --decorate --all"
alias gp='git pull'
alias gP='git push'
alias gc='git commit'
alias ga='git add'
alias rebuild='sudo nixos-rebuild switch'
alias edit-nix='sudoedit /etc/nixos/configuration.nix'
alias dots='cd ~/dotfiles'

# ─── Tooling integrations ────────────────────────────────────
# Default editor (nvim if available, else vim)
if command -v nvim >/dev/null 2>&1; then
  export EDITOR='nvim'
  export VISUAL='nvim'
  export MANPAGER='nvim +Man!'
else
  export EDITOR='vim'
  export VISUAL='vim'
fi

# bat — `ansi` inherits the kitty Catppuccin Mocha palette
export BAT_THEME="ansi"

# fzf — Catppuccin Mocha palette + fd as the source
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--height=40% --layout=reverse --border=rounded --prompt='❯ ' --pointer='▶' --marker='✚'"
  command -v fd >/dev/null 2>&1 && export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  # NixOS exposes fzf shell integrations under /run/current-system/sw/share
  for f in /run/current-system/sw/share/fzf/key-bindings.zsh /run/current-system/sw/share/fzf/completion.zsh; do
    [ -f "$f" ] && source "$f"
  done
fi

# zoxide — smarter cd; `z foo` to jump, `zi` for interactive
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd cd)"

# Starship prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ─── Greeter ─────────────────────────────────────────────────
# Show fastfetch only on the first interactive login shell so
# nested shells / tmux panes stay clean.
if [[ -o login && -z "$ZSH_RICED_GREETED" ]]; then
  export ZSH_RICED_GREETED=1
  command -v fastfetch >/dev/null 2>&1 && fastfetch
fi
