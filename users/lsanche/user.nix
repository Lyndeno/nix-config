{config, pkgs, lib, username,...}:
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
  shell = pkgs.zsh;
}