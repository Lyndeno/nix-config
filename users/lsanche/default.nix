{ config, lib, pkgs, inputs, ...}:
let
  myUsername = "lsanche";
in
{
  users.users."${myUsername}" = {
    isNormalUser = true;
    description = "Lyndon Sanche";
    home = "/home/${myUsername}";
    group = "${myUsername}";
    uid = 1000;
    extraGroups = [
      "wheel"
      "media"
      (lib.mkIf config.networking.networkmanager.enable "networkmanager") # Do not add this group if networkmanager is not enabled
    ];
    openssh.authorizedKeys.keys = [
      (lib.mkIf (config.networking.hostName == "morpheus") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEjPlzlPcny6ZKwNzdlzi85lrIhPtdjLDRov29Fbef60" )
      (lib.mkIf (config.networking.hostName == "neo") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtYA9xm9hQtFt5r7WuED1kkmvfezCURg6Tx9Ch1q0Ie" )
      (lib.mkIf (config.networking.hostName == "oracle") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG8hU9yYrAg76q1zp6rfhOBxSjwSwzQFpJTdBynWSCKA" )
    ];
    shell = pkgs.zsh;
  };
  users.groups = {
    "${myUsername}" = {};
  };
  home-manager.users."${myUsername}" = { pkgs, ... }:
  {
    imports = [
      ./home-manager/home.nix
    ];
    home.stateVersion = config.system.stateVersion;


  };
  }
