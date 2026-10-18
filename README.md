# dotfiles

[![ci](https://github.com/v420v/dotfiles/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/v420v/dotfiles/actions/workflows/ci.yml)
[![Nix flake](https://img.shields.io/badge/Nix-flake-5277C3?logo=nixos&logoColor=white)](flake.nix)
[![nix-darwin](https://img.shields.io/badge/nix--darwin-aarch64--darwin-000000?logo=apple&logoColor=white)](darwin/configuration.nix)
[![home-manager](https://img.shields.io/badge/home--manager-enabled-5277C3?logo=nixos&logoColor=white)](home/common.nix)
[![treefmt](https://img.shields.io/badge/code%20style-treefmt-blue)](treefmt.nix)
[![Neovim](https://img.shields.io/badge/Neovim-lazy.nvim-57A143?logo=neovim&logoColor=white)](nvim)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-settings-D97757?logo=anthropic&logoColor=white)](claude/settings.json)

M1 macOS (nix-darwin) config, managed with a flake and home-manager.

## macOS (M1) — nix-darwin

### Apply

```bash
# Enable flakes if you haven't:
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# First run: bootstraps darwin-rebuild, then applies system + user.
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles#<user>
```

After the first run, re-apply with (aliased to `rebuild`):

```bash
sudo darwin-rebuild switch --flake ~/dotfiles#<user>
```

User-only changes (no sudo):

```bash
home-manager switch --flake ~/dotfiles#<user>@mac    # aliased to `rebuild-home`
```

### Remove

```bash
sudo nix run nix-darwin#darwin-uninstaller          # removes nix-darwin
```

Stock files it replaced are backed up next to the originals as
`.before-nix-darwin` / `.hm-bak`; restore those if needed, then delete
`~/dotfiles`.
