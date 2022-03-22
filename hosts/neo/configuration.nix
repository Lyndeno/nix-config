# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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
    services = {
      pia-vpn.enable = true;
    };
  };

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

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    useDHCP = false;
    networkmanager.enable = true;
    networkmanager.packages = [
      pkgs.networkmanager-openvpn
    ];
  };

  services = {
    # Must create .snapshots subvolume in root of snapshotted subvolume
    #duplicati = {
    #  enable = true;
    #  dataDir = "/srv/duplicati";
    #};
    logind.lidSwitch = "suspend-then-hibernate";
    tlp.enable = true;
  };
  
  # Enable CUPS to print documents.
  services.printing.enable = true;
  modules.printers.canon.pixma.mx860.enable = true;

  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    libsmbios # For fan control
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

