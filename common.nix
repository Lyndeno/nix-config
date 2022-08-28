{ config, lib, pkgs, ...}:
let
  nebulaHosts = {
    "10.10.10.1" = [ "oracle.matrix" ];
    "10.10.10.2" = [ "morpheus.matrix" ];
    "10.10.10.3" = [ "neo.matrix" ];
  };
in
{
  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

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

  networking.hosts = nebulaHosts;

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
  ];
}
