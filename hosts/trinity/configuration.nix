{ config, lib, pkgs, ... }:

{
  networking.hostName = "trinity"; # Define your hostname.

  stylix.targets = {
    gnome.enable = false;
    gtk.enable = false;
  };

  modules.services.nebula = {
    enable = true;
    nodeName = "neo";
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

