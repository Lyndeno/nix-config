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
      ./borgbackup/borgbase.nix
    ]
    ++ (with flake.nixosModules; [
      common
      virtualisation
      zed
      desktop
      niri
      secureboot
      hydraCache
      attic-watch
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
      asus-desktop
      zfs
    ]);

  age = {
    secrets = {
      fastmail-jmap = {
        file = ../../secrets/fastmail_jmap.age;
        owner = "lsanche";
      };
    };
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

  system.stateVersion = "23.05";

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
    zfs.extraPools = ["bigpool"];
  };

  systemd.network.networks."10-ethernet".matchConfig.Name = "enp7s0";
}
