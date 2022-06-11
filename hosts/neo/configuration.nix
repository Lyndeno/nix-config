{ config, lib, pkgs, ... }:

{
  networking.hostName = "neo"; # Define your hostname.
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.2/24" ];
      listenPort = 51820;

      privateKeyFile = "/root/wg_priv";

      peers = [
        {
          publicKey = "OWi6eJW3Lic8fmWsYavw68nC5HRiB5TNbhnudwYCJ3I=";

          allowedIPs = [ "10.100.0.0/24" ];

          endpoint = "cloud.lyndeno.ca:51820";

          persistentKeepalive = 25;

          dynamicEndpointRefreshSeconds = 5;
        }
      ];
    };
  };

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
  ];

  system.stateVersion = "21.11"; # Did you read the comment?

}

