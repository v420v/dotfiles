# dotfiles

NixOS + Hyprland config, plus an M1 macOS (nix-darwin) variant. Both share the
same flake and home-manager modules.

## NixOS

### Apply

```bash
cd ~/dotfiles
./install.sh        # imports hardware-config, generates wallpaper, runs nixos-rebuild
```

Or by hand:

```bash
sudo cp /etc/nixos/hardware-configuration.nix ~/dotfiles/nixos/
sudo nixos-rebuild switch --flake ~/dotfiles#nixos
```

Re-apply after any change with the same command (aliased to `rebuild` in zsh).

### Remove

```bash
sudo nixos-rebuild switch --rollback   # go back to the previous generation
nix-collect-garbage -d                 # drop old generations
```

To fully drop it, point `nixos-rebuild` at a different `configuration.nix` and
rebuild, then delete `~/dotfiles`.

## macOS (M1) — nix-darwin

### Apply

```bash
# Enable flakes if you haven't:
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# First run: bootstraps darwin-rebuild, then applies system + user.
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles#mac
```

After the first run, re-apply with (aliased to `rebuild`):

```bash
sudo darwin-rebuild switch --flake ~/dotfiles#mac
```

User-only changes (no sudo):

```bash
home-manager switch --flake ~/dotfiles#ibuki@mac    # aliased to `rebuild-home`
```

### Remove

```bash
sudo nix run nix-darwin#darwin-uninstaller          # removes nix-darwin
```

Stock files it replaced are backed up next to the originals as
`.before-nix-darwin` / `.hm-bak`; restore those if needed, then delete
`~/dotfiles`.
