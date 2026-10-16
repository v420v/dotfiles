# dotfiles

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
