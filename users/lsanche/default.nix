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
  home-manager.users."${myUsername}" = { pkgs, ... }: {
    imports = [
      #<impermanence/home-manager.nix>
      ./home-manager/home.nix
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
    wayland.windowManager.sway.config.output = lib.mkIf (config.networking.hostName == "morpheus" ) {
      DP-1 = {
        adaptive_sync = "on";
        pos = "1920 0";
        mode = "2560x1440@144.000000Hz";
      };
      DP-2 = {
        pos = "0 300";
      };
    };
    home.stateVersion = config.system.stateVersion;

    wayland.windowManager.sway.config.workspaceOutputAssign = lib.mkIf (config.networking.hostName == "morpheus" ) [
      { workspace = "1"; output = "DP-1"; }
      { workspace = "2"; output = "DP-1"; }
      { workspace = "3"; output = "DP-1"; }
      { workspace = "4"; output = "DP-1"; }
      { workspace = "5"; output = "DP-1"; }
      { workspace = "6"; output = "DP-2"; }
      { workspace = "7"; output = "DP-2"; }
      { workspace = "8"; output = "DP-2"; }
      { workspace = "9"; output = "DP-2"; }
    ];
  };
  }
