{inputs, ...}: {
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  imports = [
    ./audio.nix
    ./network.nix
    ./stylix.nix
  ];

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
    pam.services = {
      login.u2fAuth = false;
      gdm.u2fAuth = false;
    };
  };

  services = {
    fwupd.enable = true;
    power-profiles-daemon.enable = true;
    resolved.enable = true;
    tailscale.useRoutingFeatures = lib.mkDefault "client";
    printing = {
      enable = true;
      #drivers = [ pkgs.epson-escpr2 ];
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
