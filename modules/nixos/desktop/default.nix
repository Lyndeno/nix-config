{
  lib,
  pkgs,
  perSystem,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
  ];
  age.secrets.fastmail-jmap = {
    file = ../../../secrets/fastmail_jmap.age;
    owner = "lsanche";
  };
  boot = {
    plymouth.enable = true;

    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];
  };
  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    #nixos.includeAllModules = true;
  };

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      #kdiskmark
      #rustdesk-flutter
      perSystem.ppd.default
      man-pages
      nh
      perSystem.ironfetch.default
    ];
  };

  hardware = {
    keyboard.zsa.enable = true;
    # Unlikely to NOT need this on desktop
    enableRedistributableFirmware = true;
    bluetooth.enable = lib.mkDefault true;
  };
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  programs = {
    adb.enable = true;
    dconf.enable = true;
    fish = {
      enable = true;
      useBabelfish = true;
    };
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = ["lsanche"];
    };

    _1password = {
      enable = true;
    };

    #appimage = {
    #  enable = true;
    #};
  };
  security = {
    rtkit.enable = true; # Realtime pipewire
    pam.services = {
      login.u2fAuth = false;
      gdm.u2fAuth = false;
    };
  };

  services = {
    fwupd.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    power-profiles-daemon.enable = true;
    pulseaudio.enable = false;
    resolved.enable = true;
    tailscale.useRoutingFeatures = lib.mkDefault "client";
  };

  stylix = {
    polarity = "dark";
    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };
    fonts = let
      cascadia = pkgs.nerd-fonts.caskaydia-cove;
    in {
      serif = {
        package = perSystem.apple-fonts.sf-pro-nerd;
        name = "SFProDisplay Nerd Font";
      };
      sansSerif = {
        package = perSystem.apple-fonts.sf-pro-nerd;
        name = "SFProDisplay Nerd Font";
      };
      monospace = {
        package = cascadia;
        name = "CaskaydiaCove Nerd Font Mono";
      };
      sizes = {
        desktop = 11;
        popups = 12;
      };
    };
  };

  systemd = {
    network = {
      wait-online.enable = false;
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
  };

  xdg.portal.enable = true;

  specialisation.troubleshoot = {
    configuration = {
      boot.kernelParams = [
        "fsck.mode=force"
        "debug"
      ];
      environment.etc."specialisation".text = "troubleshoot";
      boot.plymouth.enable = lib.mkForce false;
    };
  };
}
