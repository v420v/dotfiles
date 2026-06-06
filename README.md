# NixOS + Hyprland dotfiles — Modus Vivendi

Personal NixOS rice. Wayland session built around Hyprland. Managed with
**flakes + home-manager** (HM as a NixOS module — one rebuild covers
both system and user).

Also drives an **M1 MacBook (aarch64-darwin)** via **nix-darwin +
home-manager** — the portable shell/editor/CLI half of the rice plus macOS
system defaults, with no Hyprland desktop. See
[macOS](#macos-m1--nix-darwin--home-manager) below.

## Layout

```
dotfiles/
├── flake.nix                   # nixpkgs + home-manager; nixos + ibuki@mac outputs
├── flake.lock
├── nixos/
│   ├── configuration.nix       # NixOS system: boot, services, fonts, login user
│   └── hardware-configuration.nix
├── darwin/
│   └── configuration.nix       # nix-darwin system: daemon, fonts, system.defaults
├── home/
│   ├── common.nix              # cross-platform: packages + programs.{zsh,starship,...}
│   ├── ibuki.nix               # NixOS/Linux extras (Hyprland, GTK/Qt, cursor) — imports common
│   └── darwin.nix              # M1 Mac extras — imports common
├── hypr/
│   ├── hyprland.conf           # WM
│   ├── hyprpaper.conf          # wallpaper
│   ├── hyprlock.conf           # lockscreen
│   └── hypridle.conf           # idle daemon
├── waybar/{config.jsonc,style.css}
├── kitty/kitty.conf
├── rofi/{config.rasi,theme.rasi}
├── dunst/dunstrc
├── fastfetch/config.jsonc
├── nvim/                       # editor (lazy.nvim, see below)
├── wallpapers/{generate.sh,wall.png}
├── zsh/                        # legacy reference — HM owns ~/.zshrc now
├── starship/                   # legacy reference — HM owns starship config
└── install.sh                  # one-shot bootstrap
```

The `hypr/`, `waybar/`, `rofi/`, `dunst/`, `fastfetch/`, `nvim/`, and
`kitty/kitty.conf` directories are symlinked **out-of-store** into
`~/.config` by home-manager — edit them in the repo and changes are live
without a rebuild. `zsh`, `starship`, `git`, `fzf`, `bat`, `zoxide`, and
`eza` are owned by HM modules — change those, then `rebuild`.

The HM config is split so both hosts share one source of truth:

- **`home/common.nix`** — everything portable (zsh, starship, git, fzf, bat,
  zoxide, eza, the CLI package set, and the `fastfetch`/`nvim`/`kitty`
  symlinks). Builds on both `x86_64-linux` and `aarch64-darwin`.
- **`home/ibuki.nix`** — imports `common.nix`, then adds the Linux-only desktop
  (Hyprland helpers, GTK/Qt theming, X11/Wayland cursor, the pinned Linux
  `claude-code`, and the `hypr`/`waybar`/`rofi`/`dunst` symlinks). This is what
  the NixOS host imports.
- **`home/darwin.nix`** — imports `common.nix`, then adds Mac-only bits
  (`/Users/ibuki` home dir, BSD-safe aliases, `claude-code`, `coreutils`).

## Bootstrap

From a fresh NixOS install (no DE), as user `ibuki`, with this repo
checked out at `~/dotfiles`:

```bash
cd ~/dotfiles
./install.sh        # imports hardware-config, generates wallpaper, runs nixos-rebuild
```

Or by hand:

```bash
sudo cp /etc/nixos/hardware-configuration.nix ~/dotfiles/nixos/
sudo nixos-rebuild switch --flake ~/dotfiles#nixos
reboot
```

After reboot, `tuigreet` (greetd) launches. Pick `Hyprland` if not default, log in, and you're in.

Day-to-day rebuilds (also aliased as `rebuild` in zsh):

```bash
sudo nixos-rebuild switch --flake ~/dotfiles#nixos
```

## macOS (M1) — nix-darwin + home-manager

The Mac runs the **Nix package manager** with **nix-darwin** managing the system
half and **home-manager** the user half — one rebuild covers both, exactly like
the NixOS host. The split:

- `darwin/configuration.nix` — system: nix daemon, fonts, and the declarative
  `system.defaults` (dock, finder, dark mode, key repeat …).
- `home/darwin.nix` — user: shell, editor, prompt, CLI tools (imports
  `home/common.nix`, shared with NixOS).

Both are wired together in `flake.nix` under `darwinConfigurations."mac"`.

### First-time bootstrap

Nix already installed, with this repo at `~/dotfiles`:

```bash
# Enable flakes if you haven't:
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# Bootstrap nix-darwin (installs darwin-rebuild, then applies system + user).
# Needs sudo; system.defaults will retheme the dock/finder and switch to dark
# mode on this first run.
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles#mac
```

If a stock file (e.g. `/etc/zshrc`, `~/.zshrc`) is "in the way", nix-darwin /
home-manager back it up (`.before-nix-darwin`, `.hm-bak`) — that's expected.

After that, day-to-day applies are just `rebuild`:

```bash
sudo darwin-rebuild switch --flake ~/dotfiles#mac   # aliased as `rebuild`
```

### Notes

- **`rebuild`** → `sudo darwin-rebuild switch` (system + user).
  **`rebuild-home`** → `home-manager switch --flake ~/dotfiles#ibuki@mac`, the
  no-sudo standalone path for user-only changes (same `home/darwin.nix`, still
  exposed as `homeConfigurations."ibuki@mac"` for convenience).
- **`edit-nix`** → edits `darwin/configuration.nix`. `rm` drops to `rm -iv`
  (BSD has no `-I`) and `free` isn't aliased.
- **Window manager: yabai (BSP)**, enabled via `services.yabai` in
  `darwin/configuration.nix`. Runs as a launchd user agent (no manual `brew
  services` needed). Defaults to **binary space partitioning** with 8px gaps;
  hold `fn` + drag to move / resize windows. `enableScriptingAddition` is off
  because it requires SIP to be partially disabled — flip it on after
  `csrutil enable --without fs --without debug --without nvram` from recovery
  if you want shadows/animations and the few focus tweaks it unlocks.
- **Hotkey daemon: skhd**, enabled via `services.skhd`. Bindings live in
  `skhd/skhdrc` (symlinked into `~/.config/skhd/skhdrc`, edit-live like the
  hypr/kitty configs). Mod is `alt` (option) so cmd-shortcuts stay native to
  macOS. See [yabai keybinds](#yabai--skhd-keybinds-mod--alt) below. Space
  switching (`alt - 1..9`) needs the yabai scripting addition; moving a window
  to another space (`shift + alt - 1..9`) works without it.
- **GUI apps come from Homebrew Casks**, declared in `darwin/configuration.nix`
  under `homebrew.casks` (currently: Google Chrome, Arc, kitty, Raycast, Zed,
  Postman, Docker Desktop). Homebrew itself is installed and managed by **nix-homebrew**
  (a flake input) — no manual `brew` install needed; the first `rebuild` sets it
  up under `/opt/homebrew`. Add/remove apps by editing that list and running
  `rebuild`. `onActivation.cleanup = "uninstall"` removes Casks you delete from
  the list (data kept) — switch to `"none"` if you also want to `brew install`
  apps by hand.
- kitty is the Cask build (proper Spotlight/Dock `.app`); it still reads the
  shared `~/.config/kitty/kitty.conf` symlink. On NixOS, kitty stays a Nix
  package (`home/ibuki.nix`).
- Editing `nvim`/`kitty`/`fastfetch` configs is live (symlinked); changing
  packages, zsh/git/starship, Casks, or `system.defaults` needs a `rebuild`.

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

## yabai + skhd keybinds (`mod` = `alt`)

macOS only — these mirror the Hyprland layout but with `alt` (option) as the
modifier, since `cmd` is reserved for macOS-native shortcuts.

| Combo                    | Action                                |
| ------------------------ | ------------------------------------- |
| `mod` `Return`           | kitty                                 |
| `mod` `B`                | Google Chrome                         |
| `mod` `Q`                | close window                          |
| `mod` `F`                | zoom-fullscreen toggle                |
| `mod` `T`                | float toggle                          |
| `mod` `E`                | balance space                         |
| `mod` `R`                | rotate layout 90°                     |
| `mod` `Arrow` / `hjkl`   | focus                                 |
| `mod` `Shift` `Arrow`    | swap with neighbor                    |
| `mod` `Ctrl`  `Arrow`    | resize                                |
| `mod` `[1-9]`            | switch space *(needs SA)*             |
| `mod` `Shift` `[1-9]`    | move window to space                  |
| `fn` + drag              | move / resize floating window         |

Edit `skhd/skhdrc` to rebind — it's symlinked, so a save + `skhd --reload`
(skhd auto-reloads on file change anyway) picks it up. yabai config (gaps,
padding, layout) lives in `darwin/configuration.nix` under `services.yabai`
and needs a `rebuild`.

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
| fzf       | —          | Modus Vivendi-themed, `Ctrl-T` / `Alt-C` / `Ctrl-R`  |
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
- Colors: every config uses the same Modus Vivendi palette — search/replace the hex codes to switch themes.
- Bar: edit `waybar/config.jsonc` & `waybar/style.css`, then `pkill -SIGUSR2 waybar`. (Live — symlinked.)
- Hyprland reloads on save. (Live — symlinked.)
- Prompt / shell / git: edit `home/ibuki.nix`, then `rebuild`.
- System (services, hyprland enable, fonts): edit `nixos/configuration.nix`, then `rebuild`.
