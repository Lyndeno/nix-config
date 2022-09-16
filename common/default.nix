{ config, lib, pkgs, ...}:
let
  allUsers = builtins.attrNames (builtins.readDir ../users);
in
{
  imports = [
    ./theme.nix
  ];
  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  programs.fuse.userAllowOther = true;

  users.users = builtins.listToAttrs (map
    (x: {
      name = x;
      value = import ../users/${x}/user.nix { inherit config pkgs lib; username = x; };
    })
    allUsers
  );

  users.groups = builtins.listToAttrs (map
    (x: {
      name = x;
      value = {};
    })
    allUsers
  ) // {
    media = {};
  };

  home-manager.users = builtins.listToAttrs (map
    (x: {
      name = x;
      value = { pkgs, ...}: {
        imports = [ ../users/${x}/home-manager/home.nix ];
        home.stateVersion = config.system.stateVersion;
      };
    })
    allUsers
  );

  nix = {
    settings.auto-optimise-store = true;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  programs.dconf.enable = true;

  services = {
    openssh.enable = true;
    syncthing = {
      enable = true;
      user = "lsanche";
      dataDir = "/home/lsanche";
      configDir= "/home/lsanche/.config/syncthing";
      openDefaultPorts = true;
    };
  };

  security.pam = {
    u2f.enable = true;
    u2f.cue = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      pinentryFlavor = lib.mkDefault "curses";
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      enableGlobalCompInit = false;
    };
  };

  environment.systemPackages = with pkgs; [
    vim 
    #pueue
    bottom
    git
    #kdiskmark
    btrfs-progs
    busybox
    screen
  ];
}
