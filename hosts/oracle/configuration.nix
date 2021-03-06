# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  networking.hostName = "oracle"; # Define your hostname.

  #boot.loader = {
  #  systemd-boot = {
  #    enable = true;
  #    consoleMode = "max";
  #  };
  #  timeout = 3;
  #  efi.canTouchEfiVariables = true;
  #};
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  modules = {
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #networking.interfaces.wlp2s0.useDHCP = true;
  networking.interfaces.enp1s0.useDHCP = true;

  networking.networkmanager.enable = true;

  services = {
    # Must create .snapshots subvolume in root of snapshotted subvolume
  };
  
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  system.autoUpgrade = {
    enable = true;
    flake = "github:Lyndeno/nix-config/master";
    allowReboot = true;
  };

  age.secrets = {
    nebula-ca-crt.file = ./secrets/nebula.ca.crt.age;
    nebula-crt.file = ./secrets/nebula.crt.age;
    nebula-key.file = ./secrets/nebula.key.age;
  };

  services.nebula = with config.age.secrets; {
    networks = {
      matrix = {
        #settings = {
        #  lighthouse.serve_dns = true;
        #};
        key = nebula-key.path;
        cert = nebula-crt.path;
        ca = nebula-ca-crt.path;
        isLighthouse = true;
        firewall = {
          inbound = [
            {
              host = "any";
              port = "any";
              proto = "any";
            }
          ];
          outbound = [
            {
              host = "any";
              port = "any";
              proto = "any";
            }
          ];
        };
      };
    };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

