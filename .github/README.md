# nix-config

My personal NixOS configuration, managed as a Nix flake using the [Blueprint](https://github.com/numtide/blueprint) framework.

## Hosts

| Host | Role | Platform |
|------|------|----------|
| morpheus | Main desktop / home server | x86\_64 |
| neo | Personal laptop | x86\_64 |
| oracle | VPS | x86\_64 |
| trinity | Raspberry Pi backup server | aarch64 |

### morpheus

Main workstation and home server — programming, gaming, multimedia, and self-hosted services.

- CPU: AMD Ryzen 5950X — RAM: 128 GB — GPU: AMD RX 6700 XT
- Storage: 1x 512 GB NVMe (root) 2× 2 TB NVMe (system), 2× 4 TB HDD (BTRFS mirror), 6× 4 TB IronWolf via LSI HBA (ZFS RAIDZ2)
- LUKS-encrypted root
- Secure Boot via lanzaboote
- Services: Immich, Plex, Paperless-ngx, Firefly III, Vikunja, Home Assistant, Attic, Hydra, Nixarr, LubeLogger, Ollama (Vulkan)

### neo

Dell XPS 15 9560 — Intel i7-7700HQ, 64 GB RAM, 1 TB NVMe. Development laptop, occasional gaming. BorgBackup to trinity (AC power only), Secure Boot via lanzaboote.

### oracle

VPS. Tailscale exit node, acme-dns for `auth.lyndeno.ca`. Auto-upgrades nightly from GitHub.

### trinity

Raspberry Pi 4B (4 GB) + 2 TB USB HDD. BorgBackup repository host for morpheus and neo. Runs image-based A/B-updatable NixOS (systemd-repart + systemd-sysupdate).

---

## Structure

Blueprint auto-discovers modules, packages, and hosts — adding a file in the right place exposes it as a flake output.

```
hosts/<name>/configuration.nix   # per-host config
modules/nixos/<name>/default.nix  # → flake.nixosModules.<name>
modules/home/<name>/default.nix   # → flake.homeModules.<name>
packages/<name>.nix               # → flake.packages.<system>.<name>
secrets/                          # age-encrypted secrets
pubKeys.nix                       # SSH/Age public keys for hosts and users
```

## NixOS Modules

| Module | Purpose |
|--------|---------|
| `common` | Base system: Stylix theming, systemd-networkd, security, Tailscale, Nix settings |
| `desktop` | GNOME/Wayland |
| `niri` | Niri Wayland compositor |
| `laptop` | Power management, suspend/hibernate |
| `server` | Server hardening |
| `gaming` | Steam, GameMode |
| `virtualisation` | libvirt/QEMU |
| `secureboot` | Secure Boot via lanzaboote |
| `zfs` | ZFS pool support |
| `zed` | ZFS Event Daemon configuration |
| `xps-9560` | Dell XPS 15 9560 hardware quirks |
| `asus-desktop` | ASUS desktop hardware config |
| `postgresql` | PostgreSQL instance |
| `immich` | Photo library |
| `paperless` | Document management |
| `plex` | Plex Media Server |
| `nixarr` | \*arr media stack |
| `firefly` | Firefly III finance manager |
| `vikunja` | Task management |
| `home-assistant` | Home automation |
| `lubelogger` | Vehicle maintenance tracker |
| `ollama` | Local LLM inference |
| `atticd` | Attic binary cache server |
| `attic-watch` | Attic cache pusher |
| `hydraCache` | Hydra build cache config |
| `hydra-dev` | Hydra CI server |
| `localProxy` | Local reverse proxy |
| `msmtp` | SMTP relay |

## Home Manager Modules

| Module | Purpose |
|--------|---------|
| `lsanche` | Base user config, Git, SSH keys |
| `shell` | Fish, Starship, Atuin, Bat, Eza, FZF |
| `desktop` | Desktop user apps |
| `niri` | Niri user config |
| `wlroots` | Shared Wayland settings |
| `development` | Developer tools |
| `nixvim` | Neovim via nixvim |
| `email` | notmuch + mujmap |
| `vscode` | VS Code |
| `alacritty` | Terminal emulator |
| `qutebrowser` | Browser |
| `spotify` | Spotify client |
| `spotifyd` | spotifyd daemon |

## Packages

| Package | Description |
|---------|-------------|
| `battery-status` | Reports AC adapter state (`on`/`off`/`n/a`) |
| `sleep-on-battery` | Suspends-then-hibernates when on battery |
| `wb-email` | Unread email count for status bars (notmuch) |

Packages include NixOS VM tests, run via `nix flake check`.

## Theming

[Stylix](https://github.com/danth/stylix) provides system-wide theming on desktop machines — **Gruvbox Dark Hard** color scheme, Sedona wallpaper.

## Secrets

Age-encrypted `.age` files in `secrets/`. `secrets/secrets.nix` maps each secret to host public keys. Managed with `agenix`.
