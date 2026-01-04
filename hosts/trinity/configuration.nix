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
  storeSize = "2G";
in {
  imports = [
    #inputs.nixos-hardware.nixosModules.raspberry-pi-4
    flake.nixosModules.common
    (modulesPath + "/image/repart.nix")
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/image-based-appliance.nix")
    (modulesPath + "/profiles/perlless.nix")
  ];

  environment.systemPackages = with pkgs; [
    bottom
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
      device = "/dev/disk/by-partlabel/nix-store_${config.system.image.version}";
      fsType = "squashfs";
    };
  };

  system = {
    image.id = "trinity";
    image.version = "v3";
    build.sysupdate-package = let
      inherit (config.system) build;
      inherit (config.system.image) version id;
    in
      pkgs.runCommand "sysupdate-package-${version}" {} ''
        mkdir $out
        cp ${build.uki}/${config.system.boot.loader.ukiFile} $out/
        cp ${build.image}/${id}_${version}.nix-store.raw.zst $out/
        cd $out
        sha256sum * > SHA256SUMS
      '';
  };

  image.repart = {
    name = config.system.image.id;
    compression.enable = true;
    split = true;

    partitions = {
      "10-esp" = {
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
            timeout 5
          '';
        };
        repartConfig = {
          Format = "vfat";
          Label = "boot";
          SizeMinBytes = "200M";
          Type = "esp";
          SplitName = "-";
        };
      };
      "20-nix-store" = {
        storePaths = [config.system.build.toplevel];
        nixStorePrefix = "/";
        repartConfig = {
          Format = "squashfs";
          Label = "nix-store_${config.system.image.version}";
          Minimize = "off";
          SizeMinBytes = storeSize;
          SizeMaxBytes = storeSize;
          ReadOnly = "yes";
          Type = "linux-generic";
          SplitName = "nix-store";
        };
      };
      "30-empty" = {
        repartConfig = {
          Label = "_empty";
          Minimize = "off";
          SizeMinBytes = storeSize;
          SizeMaxBytes = storeSize;
          Type = "linux-generic";
          SplitName = "-";
        };
      };
    };
  };

  services.lighttpd.enable = true;

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

  systemd = {
    repart.partitions = {
      root = {
        Format = "xfs";
        Label = "root";
        Type = "root";
        Weight = 1000;
      };
    };
    sysupdate = {
      enable = true;
      transfers = let
        updateSource = {
          Path = "http://localhost/";
          Type = "url-file";
        };
      in {
        "10-nix-store" = {
          Source =
            updateSource
            // {
              MatchPattern = ["${config.system.image.id}_@v.nix-store.raw.zst"];
            };

          Target = {
            InstancesMax = 2;

            Path = "auto";

            MatchPattern = "nix-store_@v";
            Type = "partition";
            ReadOnly = "yes";
          };

          Transfer.Verify = "no";
        };
        "20-boot-image" = {
          Source =
            updateSource
            // {
              MatchPattern = ["${config.boot.uki.name}_@v.efi"];
            };
          Target = {
            # only keep 2 kernel images in the ESP partition
            InstancesMax = 2;
            MatchPattern = ["${config.boot.uki.name}_@v.efi"];

            Mode = "0444";
            # new kernels will be added to this folder,
            # old kernels removed
            Path = "/EFI/Linux";
            PathRelativeTo = "boot";

            Type = "regular-file";
          };

          Transfer.Verify = "no";
        };
      };
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
