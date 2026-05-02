{
  inputs,
  flake,
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
