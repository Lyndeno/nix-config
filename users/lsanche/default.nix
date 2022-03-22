{ config, lib, pkgs, ...}:
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
    openssh.authorizedKeys.keyFiles = [
      ../../keys/neo.pub
      ../../keys/morpheus.pub
    ];
    shell = pkgs.zsh;
  };
  users.groups = {
    "${myUsername}" = {};
  };
  home-manager.users."${myUsername}" = { pkgs, ... }:
  let
    hostConfig = ./home-manager/hosts + "/${config.networking.hostName}";
  in
  {
    imports = [
      ./home-manager/home.nix
      hostConfig
    ];
    home.modules.desktop.enable = config.modules.desktop.enable;
    home.stateVersion = config.system.stateVersion;

  };
  }
