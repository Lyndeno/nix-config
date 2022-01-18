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
    #hashedPassword = import ./passwd;
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
      #<impermanence/home-manager.nix>
      ./home-manager/home.nix
      hostConfig
    ];
    #home.persistence."/nix/persist${config.users.users.${myUsername}.home}" = let
    #  homecfg = config.home-manager.users."${myUsername}";
    #in lib.mkIf config.modules.persist.enable
    #{
    #  allowOther = true;
    #  directories = [
    #    ".ssh"
    #    "Documents"
    #    "Downloads"
    #    "Textbooks"
    #    ".mozilla"
    #    ".local/share/keyrings"
    #    ".gnupg"
    #    "Projects"
    #    ".config/syncthing"
    #  ];
    #  files = [
    #    (lib.removePrefix "$HOME" "${homecfg.programs.zsh.history.path}")
    #  ];
    #};
    home.stateVersion = config.system.stateVersion;

  };
  }
