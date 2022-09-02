{ config, lib, pkgs, ... }:

{
  networking.hostName = "trinity"; # Define your hostname.

  stylix.targets = {
    gnome.enable = false;
    gtk.enable = false;
  };

  services.borgbackup.repos = {
    neo = {
      path = "/data/borg/neo";
      authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL/jyR1sMTHU3LoSweCtlAQwtaeUJGw/2LmOAKDuEXE3" ];
    };
  };

  modules.services.nebula = {
    enable = true;
    nodeName = "trinity";
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
  };


  system.stateVersion = "22.05"; # Did you read the comment?

}

