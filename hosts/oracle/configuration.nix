{
  modulesPath,
  lib,
  config,
  flake,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/minimal.nix")
    flake.nixosModules.common
    #flake.nixosModules.hydraCache
  ];

  networking.hostName = "oracle";

  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/vda";
    };
    initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk"];
    swraid.enable = false;
  };
  # Set your time zone.
  time.timeZone = "America/Edmonton";
  networking.firewall = {
    allowedTCPPorts = [
      #80
      #443
      53
      8080
    ];
    allowedUDPPorts = [
      53
    ];
  };
  # TODO: Split stylix into own module so we do not need to do this
  stylix = {
    autoEnable = false;
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/e225c673-1c1a-4954-a822-78bf5097e646";
      fsType = "ext4";
    };
  };
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  services = {
    #invoiceplane = {
    #  webserver = "nginx";
    #  sites."invoice.lyndeno.ca" = {
    #    enable = true;
    #    settings = {
    #      IP_URL = "https://invoice.lyndeno.ca";
    #    };
    #  };
    #};
    #nginx = {
    #  enable = true;
    #  virtualHosts."invoice.lyndeno.ca" = {
    #    enableACME = true;
    #    forceSSL = true;
    #  };
    #};
    acme-dns = {
      enable = true;
      settings = {
        general = {
          nsname = "auth.lyndeno.ca";
          nsadmin = "system.lyndeno.ca";
          listen = ":53";
          domain = "auth.lyndeno.ca";
          records = [
            "auth.lyndeno.ca. A 45.63.35.22"
            "auth.lyndeno.ca. NS auth.lyndeno.ca."
          ];
        };
        api = {
          #tls = "letsencrypt";
          ip = "0.0.0.0";
          port = 8080;
          #acme_cache_dir = "api-certs";
          notification_email = "lsanche@lyndeno.ca";
        };
      };
    };
    resolved.settings.Resolve.DNSStubListener = false;
    syncthing.enable = lib.mkForce false;
    tailscale = {
      useRoutingFeatures = "server";
    };
  };
  security = {
    acme = {
      acceptTerms = true;
      defaults.email = "lsanche@lyndeno.ca";
    };
  };
  swapDevices = [
    {device = "/dev/disk/by-uuid/f5a92456-c4f1-48af-ab5f-de7e86cdaeea";}
  ];
  system = {
    autoUpgrade = {
      enable = true;
      flake = "github:Lyndeno/nix-config/master";
      allowReboot = true;
      dates = "03:00";
    };
    stateVersion = "21.11";
  };
  systemd = {
    network = {
      networks = {
        "10-enp1s0" = {
          name = "enp1s0";
          DHCP = "ipv4";
        };
      };
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
