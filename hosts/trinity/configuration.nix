{
  inputs,
  flake,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    flake.nixosModules.common
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/data/borg" = {
      device = "/dev/disk/by-label/omicron";
      fsType = "btrfs";
      options = ["noatime" "compress=zstd:6" "subvolid=256"];
    };
  };

  boot = {
    tmp.useTmpfs = true;
    swraid.enable = false;

    initrd.systemd.enable = true;

    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyS0,115200"
      "console=tty1"
      "cma=128M"
    ];
  };

  networking.wireless.iwd.enable = true;
  networking.hostName = "trinity";
  stylix.autoEnable = false;
  system.stateVersion = "22.05";

  system.autoUpgrade = {
    enable = true;
    flake = "github:Lyndeno/nix-config/master";
    allowReboot = true;
    dates = "Mon, 03:30";
  };

  services = {
    borgbackup.repos = {
      morpheus = {
        path = "/data/borg/morpheus";
        authorizedKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP6nNQlJ+zzi+fmwDnXJ4eZXbp2JrS3fe2m04DlvstkO"];
      };
      neo = {
        path = "/data/borg/neo";
        authorizedKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL/jyR1sMTHU3LoSweCtlAQwtaeUJGw/2LmOAKDuEXE3"];
      };
    };
    openssh.enable = true;
  };

  systemd.network = {
    networks = {
      "10-ethernet" = {
        matchConfig.Type = "ether";
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 100;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 100;
        };
        routes = [
          {
            Gateway = "_dhcp4";
            InitialCongestionWindow = 30;
            InitialAdvertisedReceiveWindow = 30;
          }
        ];
      };
      "20-wifi" = {
        matchConfig.Type = "wlan";
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 600;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 600;
        };
      };
    };
  };
}
