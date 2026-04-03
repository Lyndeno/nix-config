{
  pkgs,
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
      hydra-dev
      lubelogger
    ])
    ++ (with inputs.nixos-hardware.nixosModules; [
      common-gpu-amd
      common-cpu-amd
      common-cpu-amd-pstate
      common-pc-ssd
    ]);

  time.timeZone = "America/Edmonton";
  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    hostName = "morpheus";
    domain = "lyndeno.ca";
    hostId = "a5d4421d";
    firewall.logRefusedConnections = false;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  system.stateVersion = "23.05";

  environment.systemPackages = [pkgs.brasero];

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

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
  };

  age.secrets = {
    id_borgbase.file = ../../secrets/id_borgbase.age;
    pass_borgbase.file = ../../secrets/morpheus/pass_borgbase.age;
  };

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux"];
    kernelModules = ["kvm-amd" "jc42" "nct6775" "ddcci" "sg"];
    swraid.enable = false;
    initrd = {
      systemd.enable = true;
      luks.devices."cryptroot" = {
        device = "/dev/disk/by-label/nixcrypt";
        bypassWorkqueues = true;
        allowDiscards = true;
      };
      availableKernelModules = ["nvme" "mpt3sas" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
    };
    supportedFilesystems = ["zfs"];
    zfs.extraPools = ["bigpool"];
  };

  services = {
    tailscale.useRoutingFeatures = "both";
    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };
  };

  systemd.network.networks."10-ethernet".matchConfig.Name = "enp7s0";
}
