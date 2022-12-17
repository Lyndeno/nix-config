{ config, lib, pkgs, ...}:
{
  imports = [
    ./theme.nix
    ./users.nix
  ];
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
      options = "--delete-older-than 60d";
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
