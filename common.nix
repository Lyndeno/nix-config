{ config, lib, pkgs, ...}:
{
  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  nix = {
    settings.auto-optimise-store = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };

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

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim 
    #pueue
    bottom
    git
    #kdiskmark
  ];
}
