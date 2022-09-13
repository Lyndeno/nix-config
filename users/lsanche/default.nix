{ config, lib, pkgs, inputs, ...}:
let
  myUsername = "lsanche";
  keys = import ./pubkeys.nix { inherit pkgs; };
  checkKey = keys.strings ? ${config.networking.hostName};
in
{
  warnings = lib.mkIf (!checkKey) [
    "User 'lsanche' does not have valid login ssh key for hostname '${config.networking.hostName}'"
  ];
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
      (lib.mkIf config.programs.adb.enable "adbusers")
      "libvirtd"
      "dialout"
    ];
    openssh.authorizedKeys.keys = [
      (lib.mkIf checkKey keys.strings.${config.networking.hostName})
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
