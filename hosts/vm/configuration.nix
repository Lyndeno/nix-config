{ config, lib, pkgs, ... }:

{
  networking.hostName = "vm"; # Define your hostname.

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
    services = {
      #pia-vpn.enable = true;
    };
  };
  services.spice-vdagentd.enable = true;

  #networking.nat.enable = true;
  #networking.nat.internalInterfaces = [ "ve-torrents" ];
  #networking.nat.externalInterface = "wlp2s0";

  #containers.torrents = {
  #  enableTun = true;
  #  autoStart = true;
  #  privateNetwork = true;
  #  hostAddress = "192.168.100.2";
  #  localAddress = "192.168.100.11";
  #  forwardPorts = [
  #    {
  #      containerPort = 9091;
  #      hostPort = 9091;
  #      protocol = "tcp";
  #    }
  #    {
  #      containerPort = 9091;
  #      hostPort = 9091;
  #      protocol = "udp";
  #    }
  #  ];
  #  config = { config, pkgs, ... }: {
  #    services.transmission.enable = true;
  #    services.transmission.openRPCPort = true;
  #                 
  #    services.openvpn.servers = {
  #      pia-vancouver = {
  #        autoStart = false;
  #        config = "config /etc/nixos/vpn/pia-vancouver.ovpn";
  #      };
  #    };
  #  };
  #};

  #specialisation = {
  #  plexMode = {
  #    configuration = {
  #      services.plex = {
  #        enable = true;
  #        openFirewall = true;
  #        group = "media";
  #      };
  #    };
  #  };
  #};

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    useDHCP = false;
    networkmanager.enable = true;
    networkmanager.plugins = [
      pkgs.networkmanager-openvpn
    ];
  };

  services = {
    #logind.lidSwitch = "suspend-then-hibernate";
    #tlp.enable = true;
  };
  
  # Enable CUPS to print documents.
  services.printing.enable = true;
  modules.printers.canon.pixma.mx860.enable = true;

  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    libsmbios # For fan control
  ];

  system.stateVersion = "21.11"; # Did you read the comment?

}

