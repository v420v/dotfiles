# NixOS + Hyprland dotfiles — Catppuccin Mocha

Personal NixOS rice. Wayland session built around Hyprland.

## Layout

```
dotfiles/
├── nixos/configuration.nix     # System config (copied to /etc/nixos/)
├── hypr/
│   ├── hyprland.conf           # WM
│   ├── hyprpaper.conf          # wallpaper
│   ├── hyprlock.conf           # lockscreen
│   └── hypridle.conf           # idle daemon
├── waybar/{config.jsonc,style.css}
├── kitty/kitty.conf
├── zsh/.zshrc                  # interactive shell
├── starship/starship.toml      # prompt
├── rofi/{config.rasi,theme.rasi}
├── dunst/dunstrc
├── nvim/                       # editor (lazy.nvim, see below)
├── wallpapers/{generate.sh,wall.png}
└── install.sh
```

## Bootstrap

From a fresh NixOS install (no DE), as user `ibuki`:

```bash
cd ~/dotfiles
./install.sh        # symlinks user configs, then prompts to rebuild NixOS
```

Or apply by hand:

```bash
sudo cp ~/dotfiles/nixos/configuration.nix /etc/nixos/configuration.nix
sudo nixos-rebuild switch
~/dotfiles/wallpapers/generate.sh   # once magick is installed
./install.sh                         # again to symlink configs
reboot
```

After reboot, `tuigreet` (greetd) launches. Pick `Hyprland` if not default, log in, and you're in.

## Default keybinds (`SUPER` = mod)

| Combo                  | Action                        |
| ---------------------- | ----------------------------- |
| `mod` `Return`         | kitty                         |
| `mod` `R`              | rofi launcher                 |
| `mod` `E`              | thunar                        |
| `mod` `B`              | firefox                       |
| `mod` `V`              | clipboard history             |
| `mod` `Q`              | close window                  |
| `mod` `F`              | fullscreen                    |
| `mod` `T`              | float toggle                  |
| `mod` `L`              | lock                          |
| `mod` `Shift` `E`      | exit Hyprland                 |
| `mod` `[1-0]`          | switch workspace              |
| `mod` `Shift` `[1-0]`  | move window to workspace      |
| `mod` `Arrow` / `hjkl` | focus                         |
| `mod` `Shift` `Arrow`  | move window                   |
| `mod` `Ctrl` `Arrow`   | resize                        |
| `Print`                | screenshot region (clipboard) |
| `Shift` `Print`        | screenshot region (save)      |
| `mod` `Print`          | screenshot full output        |

Volume / brightness / media keys are wired to pamixer / brightnessctl / playerctl.

## Japanese input (fcitx5 + mozc)

Already enabled in `configuration.nix`. After login, toggle with the fcitx5 default (`Ctrl+Space`); tray icon lives in waybar.

## Shell — zsh + starship

Highlights baked in:

| Tool      | Replaces   | Notes                                                |
| --------- | ---------- | ---------------------------------------------------- |
| eza       | ls         | `ll` / `la` / `lt` aliases, git column               |
| bat       | cat / less | uses `ansi` theme so it inherits kitty's palette     |
| ripgrep   | grep       | `rg` aliased as `grep`                               |
| fd        | find       | also drives fzf's file source                        |
| fzf       | —          | Catppuccin-themed, `Ctrl-T` / `Alt-C` / `Ctrl-R`     |
| zoxide    | cd         | `cd foo` jumps to the most-frecent match             |
| btop      | top        | aliased                                              |
| starship  | PS1        | two-line powerline prompt, OS / git / lang / runtime |
| fastfetch | neofetch   | runs once on login                                   |

Convenience aliases: `rebuild` → `sudo nixos-rebuild switch`,
`edit-nix` → `sudoedit /etc/nixos/configuration.nix`, `dots` → `cd ~/dotfiles`,
plus the usual `gs`/`gd`/`gl`/`gp`/`gP`/`gc`/`ga` git shortcuts.

## Editor — neovim + lazy.nvim

`nvim/` is a from-scratch Lua config built on [lazy.nvim](https://github.com/folke/lazy.nvim).
First launch: `nvim` will bootstrap lazy and install everything. Run `:Lazy
sync` afterwards to pin lockfile.

Layout:

```
nvim/
├── init.lua
└── lua/
    ├── config/{options,keymaps,lazy}.lua
    └── plugins/{colorscheme,treesitter,lsp,completion,
                 telescope,ui,editor,claude}.lua
```

Why no Mason: NixOS doesn't run dynamically-linked binaries from upstream
release tarballs. Every language server / formatter is a system package
in `configuration.nix` instead — `nvim-lspconfig` just picks them up
from `$PATH`.

Languages wired in:

| Stack    | LSP / formatter                                     | Treesitter            |
| -------- | --------------------------------------------------- | --------------------- |
| Go       | `gopls`, `gofumpt`, `goimports`                     | go / mod / sum / work |
| TS / JS  | `typescript-language-server`, `prettierd`, `eslint` | js / ts / tsx         |
| HTML/CSS | `vscode-langservers-extracted`, `prettierd`         | html / css / scss     |
| C / C++  | `clangd`, `clang-format`                            | c / cpp               |
| Asm      | `asm-lsp`                                           | asm                   |
| Lua      | `lua-language-server`, `stylua`                     | lua                   |
| Nix      | `nil`, `nixpkgs-fmt`                                | nix                   |
| Bash     | `bash-language-server`, `shfmt`                     | bash                  |

Format-on-save is on by default (`conform.nvim`); toggle with `:FormatDisable[!]`
/ `:FormatEnable`.

### Claude Code in nvim

Uses [coder/claudecode.nvim](https://github.com/coder/claudecode.nvim),
which talks to the system `claude` CLI (already in `configuration.nix`).
Opens an interactive session in a snacks-managed split on the right and
streams diffs back into nvim.

### Keymap cheat-sheet (`<leader>` = `Space`)

| Combo              | Action                          |
| ------------------ | ------------------------------- |
| `<leader>w` / `q`  | save / quit                     |
| `-`                | open parent dir (oil)           |
| `<leader>ff`       | find files                      |
| `<leader>fg`       | live grep                       |
| `<leader>fb`       | buffers                         |
| `<leader>fr`       | recent files                    |
| `<leader>fs`       | document symbols                |
| `<leader>/`        | fuzzy in current buffer         |
| `gd` / `gr` / `gi` | LSP definition / refs / impl    |
| `K` / `<C-k>`      | hover / signature help          |
| `<leader>rn`       | rename symbol                   |
| `<leader>ca`       | code action / **diff accept**   |
| `<leader>cf`       | format buffer                   |
| `]d` / `[d`        | next / prev diagnostic          |
| `]h` / `[h`        | next / prev git hunk            |
| `<leader>hp/r/s`   | preview / reset / stage hunk    |
| **`<leader>cc`**   | toggle Claude session           |
| `<leader>cf`       | focus Claude window             |
| `<leader>cb`       | send current buffer to Claude   |
| `<leader>cs`       | send visual selection to Claude |
| `<leader>cR/cC`    | resume / continue last session  |
| `<leader>cd`       | deny pending Claude diff        |

`which-key` shows the rest live — just press `<leader>` and wait.

## Customizing the rice

- Wallpaper: drop any image at `wallpapers/wall.png` (or rerun `generate.sh`).
- Colors: every config uses the same Catppuccin Mocha palette — search/replace the hex codes to switch flavors.
- Bar: edit `waybar/config.jsonc` & `waybar/style.css`, then `pkill -SIGUSR2 waybar`.
- Prompt: tweak `starship/starship.toml` — changes apply on the next prompt.
- Hyprland reloads on save.
