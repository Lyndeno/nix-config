{ config, lib, pkgs, ... }:

{
  networking.hostName = "neo"; # Define your hostname.


  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 25;
    timeout = 3;
    efi.canTouchEfiVariables = true;
  };

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  modules = {
    desktop.enable = true;
    desktop.environment = "sway";
    desktop.mainResolution = {
      height = 1080;
      width = 1920;
    };
    services = {
      pia-vpn.enable = true;
    };
  };

  stylix.targets = {
    gnome.enable = false;
    gtk.enable = false;
  };

  modules.services.nebula = {
    enable = true;
    nodeName = "neo";
  };

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
    networkmanager.plugins = [
      pkgs.networkmanager-openvpn
    ];
  };

  services = {
    logind.lidSwitch = "suspend-then-hibernate";
    power-profiles-daemon.enable = true;
  };
  
  # Enable CUPS to print documents.
  services.printing.enable = true;
  modules.printers.canon.pixma.mx860.enable = true;

  services.fstrim.enable = true;

  home-manager.users.lsanche.wayland.windowManager.sway.config = let
      brightness = value: "${pkgs.brightnessctl}/bin/brightnessctl set ${value} | sed -En 's/.*\\(([0-9]+)%\\).*/\\1/p' > $XDG_RUNTIME_DIR/wob.sock";
  in{
      keybindings = lib.mkOptionDefault {
        # TODO: Figure out how to make this conditional on host
        "XF86MonBrightnessUp" = "exec ${brightness "+5%"}";
        "XF86MonBrightnessDown" = "exec ${brightness "5%-"}";
      };
    };

  home-manager.users.lsanche.services.kanshi = {
      enable = true;
      profiles = let
        main_screen = "eDP-1";
        zenscreen = "Unknown ASUS MB16AC J6LMTF097058";
      in {
        single = {
          outputs = [{
            criteria = main_screen;
            scale = 1.0;
            position = "0,0";
          }];
        };
        with_zenscreen = {
          outputs = [
            {
              criteria = main_screen;
              scale = 1.0;
              position = "0,0";
            }
            {
              criteria = zenscreen;
              scale = 1.0;
              position = "1920,0";
            }
          ];
        };
      };
    };

  environment.systemPackages = with pkgs; [
    libsmbios # For fan control
    transmission-qt
    virt-manager
  ];

  system.stateVersion = "21.11"; # Did you read the comment?

}

