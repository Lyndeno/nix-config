{ config, lib, pkgs, ...}:
{
  users.users.lsanche = {
    isNormalUser = true;
    description = "Lyndon Sanche";
    home = "/home/lsanche";
    group = "lsanche";
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
    lsanche = {};
  };
  home-manager.users.lsanche = { pkgs, ... }: {
    imports = [
      <impermanence/home-manager.nix>
      ./home-manager/home.nix
    ];
    home.persistence."/nix/persist/home/lsanche" = let
      homecfg = config.home-manager.users.lsanche;
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
