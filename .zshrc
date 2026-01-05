# .zshrc

# git clone https://github.com/cybardev/zen.zsh.git ~/.zsh/zen
fpath+="$HOME/.zsh/zen"
autoload -Uz promptinit
promptinit
prompt zen


# -- plugins --
ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"
ZSH_SYNTAX_DIR="$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
ZSH_SUGGESTIONS_DIR="$ZSH_PLUGIN_DIR/zsh-autosuggestions"

if [[ ! -d "$ZSH_SYNTAX_DIR" ]]; then
  mkdir -p "$ZSH_PLUGIN_DIR"
  git clone --depth=1 git@github.com:zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_DIR"
fi
source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if [[ ! -d "$ZSH_SUGGESTIONS_DIR" ]]; then
  mkdir -p "$ZSH_PLUGIN_DIR"
  git clone --depth=1 git@github.com:zsh-users/zsh-autosuggestions.git "$ZSH_SUGGESTIONS_DIR"
fi
source ~/zsh-autosuggestions/zsh-autosuggestions.zsh


# -- zsh_aliases --
if [ -f ~/.zsh_aliases ]; then
  . ~/.zsh_aliases
fi


# -- paths --
if [[ false ]]; then
  export PATH="$HOME/node-v24.12.0-linux-x64/bin:$PATH"
  export PATH="$HOME/nvim-linux-x86_64/bin:$PATH"
fi

if [[ false ]]; then
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
  export PATH="/opt/homebrew/opt/bison/bin:$PATH"
  export PATH="/opt/homebrew/opt/libiconv/bin:$PATH"
  export PATH="/opt/homebrew/opt/libxml2/bin:$PATH"
  export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
  export PATH="$HOME/pkg/node/node-v24.11.1-darwin-arm64/bin:$PATH"
  #export PATH="$HOME/pkg/node/node-v22.21.1-darwin-arm64/bin:$PATH"
fi

if [[ true ]]; then
  export PATH="$HOME/.volta/bin:$PATH"
  export PATH="/opt/homebrew/opt/bison/bin:$PATH"
  export PATH="/opt/homebrew/opt/libiconv/bin:$PATH"
  export PATH="/opt/homebrew/opt/libxml2/bin:$PATH"
  export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
fi


