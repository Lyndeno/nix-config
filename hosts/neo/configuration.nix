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
    desktop.environment = "plasma";
    services = {
      pia-vpn.enable = true;
    };
  };

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
    networkmanager.packages = [
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

  environment.systemPackages = with pkgs; [
    libsmbios # For fan control
    transmission-qt
  ];

  system.stateVersion = "21.11"; # Did you read the comment?

}

