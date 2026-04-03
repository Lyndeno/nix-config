{
  config,
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

  nix = {
    buildMachines = [
      {
        hostName = "localhost";
        protocol = null;
        systems = ["x86_64-linux" "aarch64-linux"];
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark" "gccarch-znver3" "gccarch-skylake"];
        maxJobs = 32;
      }
    ];
    settings = {
      allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
        "https://devimages-cdn.apple.com/"
      ];
      system-features = [
        "kvm"
        "nixos-test"
        "big-parallel"
        "benchmark"
        "gccarch-znver3"
        "gccarch-skylake"
      ];
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "lsanche@lyndeno.ca";
      dnsProvider = "acme-dns";
      environmentFile = pkgs.writeText "acme-env" ''
        ACME_DNS_API_BASE=http://oracle:8080
        ACME_DNS_STORAGE_PATH=/var/lib/acme/.lego-acme-dns-accounts.json
      '';
    };
    certs."${config.networking.domain}" = {
      inherit (config.services.nginx) group;
      domain = "*.${config.networking.domain}";
    };
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
    id_trinity_borg.file = ../../secrets/morpheus/id_trinity_borg.age;
    pass_trinity_borg.file = ../../secrets/morpheus/pass_trinity_borg.age;
    pangolin.file = ../../secrets/morpheus/pangolin.age;
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
