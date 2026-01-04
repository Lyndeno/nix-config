{
  inputs,
  flake,
  modulesPath,
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) efiArch;
in {
  imports = [
    #inputs.nixos-hardware.nixosModules.raspberry-pi-4
    flake.nixosModules.common
    (modulesPath + "/image/repart.nix")
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/image-based-appliance.nix")
    (modulesPath + "/profiles/perlless.nix")
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partlabel/root";
      fsType = "xfs";
    };
    "/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
    };
    "/nix/store" = {
      device = "/dev/disk/by-partlabel/nix-store";
      fsType = "squashfs";
    };
  };

  image.repart = {
    name = "image";
    compression.enable = true;

    partitions = {
      esp = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

          "/EFI/Linux/${config.system.boot.loader.ukiFile}".source = "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";

          "/firmware".source = "${inputs.rpi4-uefi}/firmware";
          "/overlays".source = "${inputs.rpi4-uefi}/overlays";
          "/bcm2711-rpi-4-b.dtb".source = "${inputs.rpi4-uefi}/bcm2711-rpi-4-b.dtb";
          "/bcm2711-rpi-400.dtb".source = "${inputs.rpi4-uefi}/bcm2711-rpi-400.dtb";
          "/bcm2711-rpi-cm4.dtb".source = "${inputs.rpi4-uefi}/bcm2711-rpi-cm4.dtb";
          "/config.txt".source = "${inputs.rpi4-uefi}/config.txt";
          "/fixup4.dat".source = "${inputs.rpi4-uefi}/fixup4.dat";
          "/RPI_EFI.fd".source = "${inputs.rpi4-uefi}/RPI_EFI.fd";
          "/start4.elf".source = "${inputs.rpi4-uefi}/start4.elf";

          "/loader/loader.conf".source = builtins.toFile "loader.conf" ''
            timeout 20
          '';
        };
        repartConfig = {
          Format = "vfat";
          Label = "boot";
          SizeMinBytes = "200M";
          Type = "esp";
        };
      };
      nix-store = {
        storePaths = [config.system.build.toplevel];
        nixStorePrefix = "/";
        repartConfig = {
          Format = "squashfs";
          Label = "nix-store";
          Minimize = "guess";
          ReadOnly = "yes";
          Type = "linux-generic";
        };
      };
    };
  };

  boot = {
    loader.grub.enable = false;
    loader.systemd-boot.enable = true;
    initrd.systemd = {
      enable = true;
      emergencyAccess = true;
    };

    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyS0,115200"
      "console=tty1"
      "cma=128M"
    ];

    initrd.systemd.repart = {
      enable = true;
      device = "/dev/mmcblk1";
    };
  };

  systemd.repart.partitions = {
    root = {
      Format = "xfs";
      Label = "root";
      Type = "root";
      Weight = 1000;
    };
  };

  networking.wireless.iwd.enable = true;
  networking.hostName = "trinity";
  stylix.autoEnable = false;
  system.stateVersion = "25.11";

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
        networkConfig.MulticastDNS = true;
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
        networkConfig.MulticastDNS = true;
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
