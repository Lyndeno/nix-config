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
      stylix
      syncthing
      virtualisation
      zed
      desktop
      niri
      secureboot
      hydraCache
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
      asus-desktop
      zfs
    ]);

  services.lyndenoAcme.enable = true;

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

  # systemd-oomd: on this build/service host a runaway nix build can drive the
  # machine into swap thrash before the kernel OOM killer reacts. Let oomd act
  # first, based on cgroup pressure/swap, so it kills the offending cgroup
  # cleanly. Monitor the root slice (swap exhaustion, incl. zram above) plus
  # the system and user slices (sustained memory pressure). Tradeoff: under
  # heavy pressure oomd may kill a well-behaved service in system.slice, not
  # just the build — acceptable here since everything is restartable.
  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
    extraConfig = {
      # Require pressure to persist before acting, to avoid twitchy kills
      # during normal build spikes.
      DefaultMemoryPressureDurationSec = "20s";
    };
  };

  system = {
    autoUpgrade = {
      enable = true;
      flake = "github:Lyndeno/nix-config/master";
      allowReboot = true;
      dates = "03:00";
      rebootWindow = {
        lower = "01:00";
        upper = "05:00";
      };
    };
  };

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
