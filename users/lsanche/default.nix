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
      "libvirtd"
    ];
    openssh.authorizedKeys.keys = let
      keys = import ./pubkeys.nix { inherit pkgs; };
    in [
      (lib.mkIf (config.networking.hostName == "morpheus") keys.strings.morpheus )
      (lib.mkIf (config.networking.hostName == "neo") keys.strings.neo )
      (lib.mkIf (config.networking.hostName == "oracle") keys.strings.oracle )
      (lib.mkIf (config.networking.hostName == "trinity") keys.strings.trinity )
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
