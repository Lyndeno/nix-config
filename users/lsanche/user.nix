{config, pkgs, lib, username,...}:
let
  keys = (import ./info.nix ).hostAuthorizedKeys;
  checkKey = keys ? ${config.networking.hostName};
in
{
  isNormalUser = true;
  description = "Lyndon Sanche";
  home = "/home/${username}";
  group = "${username}";
  uid = 1000;
  extraGroups = [
    "wheel"
    "media"
    (lib.mkIf config.networking.networkmanager.enable "networkmanager") # Do not add this group if networkmanager is not enabled
    (lib.mkIf config.programs.adb.enable "adbusers")
    "libvirtd"
    "dialout"
  ];
  openssh.authorizedKeys.keys = [
    (lib.mkIf checkKey keys.${config.networking.hostName})
  ];
  shell = pkgs.zsh;
}