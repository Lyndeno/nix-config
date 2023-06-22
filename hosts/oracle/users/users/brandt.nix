{
  pkgs,
  config,
  lib,
}: let
  pubKeys = import ../../../../home/brandt/pubKeys.nix;
in {
  isNormalUser = true;
  description = "Brandt Sanche";
  extraGroups = [
    "wheel"
  ];
  shell = pkgs.zsh;
  openssh.authorizedKeys.keys = [
    (lib.mkIf (pubKeys ? ${config.networking.hostName}) pubKeys.${config.networking.hostName})
  ];
}
