{
  inputs,
  flake,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    "${inputs.nixos-hardware}/dell/xps/15-9560/intel"
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    flake.nixosModules.common
    flake.nixosModules.virtualisation
    flake.nixosModules.desktop
    flake.nixosModules.niri
    flake.nixosModules.secureboot
    flake.nixosModules.laptop
    ./borgbackup/borgbase.nix
    ./disko.nix
  ];

  system.stateVersion = "21.11";

  nixpkgs.hostPlatform = "x86_64-linux";

  specialisation = {
    nvidia = {
      configuration = {
        imports = [
          inputs.nixos-hardware.nixosModules.dell-xps-15-9560-nvidia
        ];

        disabledModules = [
          "${inputs.nixos-hardware}/dell/xps/15-9560/intel"
        ];
        services.switcherooControl.enable = true;
        hardware.nvidia = {
          modesetting.enable = true;
          open = false;
          nvidiaSettings = false;
        };
        # For nh
        environment.etc."specialisation".text = "nvidia";
      };
    };
  };

  age = {
    secrets = {
      id_borgbase.file = ../../secrets/id_borgbase.age;
      pass_borgbase.file = ../../secrets/neo/pass_borgbase.age;

      id_trinity_borg.file = ../../secrets/neo/id_trinity_borg.age;
      pass_trinity_borg.file = ../../secrets/neo/pass_trinity_borg.age;
    };
  };

  boot = {
    swraid.enable = false;
    initrd = {
      systemd = {
        enable = true;
      };
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      kernelModules = [
        "kvm-intel"
        "tpm_tis"
      ];
    };
    kernelParams = [
      "acpi_rev_override=1" # nvidia card crashes things without this
      "intel_iommu=on"
    ];
    kernelModules = [
      "coretemp" # sensors-detect for Intel temperature
    ];
    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  networking = {
    hostName = "neo";
    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          AddressRandomization = "network";
        };
      };
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
  };

  services = {
    upower.criticalPowerAction = "Hibernate";
    tailscale.useRoutingFeatures = "client";
    automatic-timezoned.enable = true;
    geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
  };

  systemd = {
    network = {
      wait-online.enable = false;
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
    services.borgbackup-job-borgbase.unitConfig.ConditionACPower = true;
  };
}
