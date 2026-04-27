{inputs, ...}: {
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
in {
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
    man.cache = {
      enable = true;
      generateAtRuntime = true;
    };
    #nixos.includeAllModules = true;
  };

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      #kdiskmark
      #rustdesk-flutter
      inputs.ppd.packages.${system}.default
      man-pages
      nh
      inputs.ironfetch.packages.${system}.default
      ncdu
      smartmontools
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
    printing = {
      enable = true;
      #drivers = [ pkgs.epson-escpr2 ];
    };
  };

  stylix = {
    polarity = "dark";
    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };
    opacity = {
      terminal = 0.8;
      popups = 0.8;
      desktop = 0.8;
    };
    fonts = let
      cascadia = pkgs.nerd-fonts.caskaydia-cove;
    in {
      serif = {
        package = inputs.apple-fonts.packages.${system}.sf-pro-nerd;
        name = "SFProDisplay Nerd Font";
      };
      sansSerif = {
        package = inputs.apple-fonts.packages.${system}.sf-pro-nerd;
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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
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

  systemd = {
    network = {
      wait-online.enable = false;
      networks = {
        "05-virt" = {
          matchConfig.Name = "vnet*";
          linkConfig.Unmanaged = "yes";
        };
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
