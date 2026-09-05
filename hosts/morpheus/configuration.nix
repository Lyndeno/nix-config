{
  inputs,
  flake,
  pkgs,
  ...
}: {
  imports =
    [
      inputs.disko.nixosModules.default
      ./disko.nix
      ./borgbackup
    ]
    ++ (with flake.nixosModules; [
      common
      stylix
      syncthing
      virtualisation
      zed
      desktop
      niri
      secureboot
      hydraCache
      modprobed-db
      attic-watch
      acme
      localProxy
      server
      postgresql
      immich
      nixarr
      firefly
      paperless
      vikunja
      atticd
      ollama
      home-assistant
      plex
      hydra
      lubelogger
      calibre-web
      asus-desktop
      zfs
      failure-notify
      gpu-coredump
      borgmatic
    ]);

  services = {
    lyndenoAcme.enable = true;

    # Accumulating toward a localmodconfig-derived kernel; this host's module
    # set only shows up in full once every disk, VM, and service has run.
    modprobedDb.enable = true;

    # The RX 6700 XT intermittently hangs the graphics ring and takes the
    # session with it; the kernel deletes its coredump minutes later, so grab
    # it on sight.
    gpuCoredump.enable = true;

    failureNotify = {
      enable = true;
      units = [
        "borgmatic"
        "immich-stack"
        "nix-gc"
      ];
    };
  };

  hostMeta = {
    description = "Main workstation and home server — programming, gaming, multimedia, and self-hosted services.";
    specs = ''
      - CPU: AMD Ryzen 5950X — RAM: 128 GB — GPU: AMD RX 6700 XT
      - Storage: 1× 512 GB NVMe (root), 2× 2 TB NVMe (system), 2× 4 TB HDD (BTRFS mirror), 6× 4 TB IronWolf via LSI HBA (ZFS RAIDZ2)
      - LUKS-encrypted root, Secure Boot via lanzaboote
      - Services: Immich, Plex, Paperless-ngx, Firefly III, Vikunja, Home Assistant, Attic, Hydra, Nixarr, LubeLogger, Ollama
    '';
  };

  age = {
    secrets = {
      fastmail-jmap = {
        file = ../../secrets/fastmail_jmap.age;
        owner = "lsanche";
      };
    };
  };

  nix.gc = let
    maxFreed = 200; # GB
  in {
    dates = "daily";
    options = "--delete-older-than 14d --max-freed \"$((${toString maxFreed} * 1024**3 - 1024 * $(df --output=avail /nix/store | tail -n 1)))\"";
  };

  time.timeZone = "America/Edmonton";
  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    hostName = "morpheus";
    domain = "lyndeno.ca";
    # For ZFS
    hostId = "a5d4421d";
  };

  users.groups.builder = {};
  users.users.builder = {
    isSystemUser = true;
    group = "builder";
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+/C/kSJUTqvnRXdq86551K1k1x1YG57Oc68b9nDsED"
    ];
  };

  nix.settings.trusted-users = ["builder"];

  zramSwap.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixroot";
      fsType = "xfs";
    };
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux"];
    initrd = {
      systemd.enable = true;
      luks.devices."cryptroot" = {
        device = "/dev/disk/by-label/nixcrypt";
        bypassWorkqueues = true;
        allowDiscards = true;
      };
    };
    zfs = {
      forceImportRoot = false;
      extraPools = ["bigpool"];
    };
  };

  systemd.network.networks."10-ethernet".matchConfig.Name = "enp7s0";

  # Do not change. See `man configuration.nix` — pins stateful defaults to NixOS version at install time.
  system.stateVersion = "23.05";
}
