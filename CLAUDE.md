# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a multi-host NixOS configuration using Nix flakes, managed via the [Blueprint](https://github.com/numtide/blueprint) framework. It covers 4 machines: **morpheus** (desktop/server), **neo** (laptop), **oracle** (VM), and **trinity** (minimal).

## Applying Configuration

```bash
# Switch the running system to a host config
nixos-rebuild switch --flake .#HOST

# Or from GitHub directly
nixos-rebuild switch --flake github:Lyndeno/nix-config#HOST

# Build without switching
nixos-rebuild build --flake .#HOST
```

## Development Environment

```bash
# Enter dev shell (provides agenix, statix, deadnix + git hooks)
nix develop

# Or use direnv (auto-activates via .envrc)
direnv allow
```

## Linting and Formatting

These run automatically as git pre-commit hooks when inside `nix develop`:

```bash
# Format Nix files
alejandra .

# Lint Nix files
statix check .

# Find dead code
deadnix .

# Run all checks explicitly
nix flake check
```

## Secrets Management (agenix)

Secrets are Age-encrypted `.age` files in `secrets/`. Access control is defined in `secrets/secrets.nix` using public keys from `pubKeys.nix`.

```bash
# Edit a secret (must be in nix develop shell)
agenix -e secrets/some-secret.age

# Re-key all secrets (after adding a new host key)
agenix -r
```

Secrets are referenced in modules via `age.secrets.<name>.file` and the decrypted path is available at `config.age.secrets.<name>.path`.

## Architecture

### Blueprint Framework

Blueprint auto-discovers and exposes:
- `modules/nixos/*/default.nix` → `flake.nixosModules.<name>`
- `modules/home/*/default.nix` → `flake.homeModules.<name>`
- `hosts/*/configuration.nix` → NixOS system outputs

### Host Configuration Pattern

Each host lives in `hosts/<name>/configuration.nix` and follows this pattern:

```nix
{inputs, flake, ...}: {
  imports = [
    inputs.disko.nixosModules.default
    ./disko.nix
    (with flake.nixosModules; [ common module1 module2 ])
  ];
  networking.hostName = "hostname";
  system.stateVersion = "XX.YY";
}
```

### Module Pattern

Modules in `modules/nixos/` and `modules/home/` each have a `default.nix`. They receive standard NixOS args plus `inputs` and `flake`. Use `lib.mkDefault` for overrideable values and `lib.mkIf` for conditional logic.

### Key Modules

- **common** (nixos) — Base system config: Stylix theming, systemd, security, Tailscale, Nix settings
- **desktop** (nixos) — GNOME/Wayland setup; **niri** — Niri Wayland compositor
- **server** (nixos) — Server hardening and base services
- **lsanche** (home) — User-level config: Git, SSH keys pulled from `pubKeys.nix`
- **shell** (home) — Fish shell + Starship, Atuin, Bat, Eza, FZF

### Theming

Stylix is used globally for theming. Base color scheme is Gruvbox Dark Hard with the Sedona wallpaper (from the `wallpapers` flake input).

### Adding a New Secret

1. Add the secret file path and recipient public keys to `secrets/secrets.nix`
2. Run `agenix -e secrets/<name>.age` to create/edit the encrypted file
3. Reference in a module: `age.secrets.<name>.file = ../../secrets/<name>.age;`
4. Use the decrypted path: `config.age.secrets.<name>.path`

### Adding a New Host

1. Create `hosts/<name>/configuration.nix` (and optionally `disko.nix`, `README.md`)
2. Add host SSH key to `pubKeys.nix`
3. Add the key to relevant secrets in `secrets/secrets.nix`
4. Re-key secrets: `agenix -r`
