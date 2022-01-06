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
    passwordFile = "/etc/nixos/users/lsanche/passwd";
  };
  users.groups = {
    "${myUsername}" = {};
  };
  home-manager.users."${myUsername}" = { pkgs, ... }: {
    imports = [
      <impermanence/home-manager.nix>
      ./home-manager/home.nix
    ];
    home.persistence."/nix/persist${config.users.users.${myUsername}.home}" = let
      homecfg = config.home-manager.users."${myUsername}";
    in
    {
      allowOther = true;
      directories = [
        ".ssh"
        "Documents"
        "Downloads"
        ".mozilla"
        ".local/share/keyrings"
        ".gnupg"
        "Projects"
      ];
      files = [
        (lib.removePrefix "$HOME" "${homecfg.programs.zsh.history.path}")
      ];
    };
    home.stateVersion = "21.11";
  };
  }
