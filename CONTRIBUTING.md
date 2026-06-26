# Contributing

## Prerequisites

You need **Nix with flakes enabled**. See the [README](README.md) for installation
and first-run instructions.

Enable flakes once if you haven't already:

```sh
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

## Dev shell

All linters and formatters are pinned in `flake.nix`. Drop into the dev shell
to put them on your `PATH`:

```sh
nix develop
```

You only need to do this once per terminal session. Every command below assumes
you are inside the dev shell (or that the tools are otherwise available).

## Auto-format before checking

Run the in-place formatters before committing:

```sh
bash tests/format.sh
```

This formats shell scripts with `shfmt`, Nix files with `nixpkgs-fmt`, and
TOML files with `taplo`.

## Check before committing

```sh
bash tests/check.sh
```

The script lints and parses every config in the repo:

| Section | Tools |
|---------|-------|
| Shell   | `bash -n` (syntax), `shellcheck` (lint), `shfmt -d` (format diff) |
| Nix     | `nix-instantiate --parse` (syntax), `nixpkgs-fmt --check`, `statix check`, `deadnix` |
| Lua     | `luac -p` (syntax) |
| TOML    | `taplo format --check` + `taplo lint` |
| JSON    | `jq -e` (valid JSON) |

If a tool is missing it is skipped with a `∼ skip` line. Inside `nix develop`
all tools are present and no checks are skipped.

The script exits 0 (`OK`) on success and 1 (`FAILED`) on any failure, printing
the offending output indented under the failing check.

## Applying changes

After editing Nix files, rebuild to apply them.

**NixOS**

```sh
rebuild
# expands to: sudo nixos-rebuild switch --flake ~/dotfiles#nixos
```

**macOS (nix-darwin)**

```sh
rebuild
# expands to: sudo darwin-rebuild switch --flake ~/dotfiles#<user>

rebuild-home   # user-only changes, no sudo
# expands to: home-manager switch --flake ~/dotfiles#<user>@mac
```

Both `rebuild` and `rebuild-home` are shell aliases defined in
`home/ibuki.nix` (NixOS) and `home/darwin.nix` (macOS). They are available
after the first successful rebuild.

## What CI checks

CI (`.github/workflows/ci.yml`) runs two jobs on every push and pull request:

- **check** — runs `bash tests/check.sh` inside `nix develop` (no skipped tools).
- **format** — verifies that `shfmt`, `nixpkgs-fmt`, and `taplo` produce no
  diff (i.e. files are already formatted).

PRs must pass both jobs. Run `bash tests/format.sh` then `bash tests/check.sh`
locally before pushing to avoid CI failures.
