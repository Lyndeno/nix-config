{ config, lib, pkgs, ...}:
{
  imports = [ ./lsanche ];
  users = {
    mutableUsers = false;
    groups = {
      media = {};
    };
  };
  users.users.root.hashedPassword = import ./root/passwd;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  programs.fuse.userAllowOther = true;
}
