{
  pkgs,
  lib,
  config,
}: let
  pubKeys = import ../../../home/lsanche/programs/ssh/_pubKeys.nix;
in {
  isNormalUser = true;
  description = "Lyndon Sanche";
  uid = 1000;
  extraGroups = [
    "wheel"
    "media"
    (lib.mkIf config.networking.networkmanager.enable "networkmanager") # Do not add this group if networkmanager is not enabled
    (lib.mkIf config.programs.adb.enable "adbusers")
    "libvirtd"
    "dialout"
    "plugdev"
    "uaccess"
  ];
  shell = pkgs.zsh;
  openssh.authorizedKeys.keys = [
    (lib.mkIf (pubKeys ? ${config.networking.hostName}) pubKeys.${config.networking.hostName})
  ];
}
