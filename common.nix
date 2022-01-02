{ config, lib, pkgs, ...}:
{
  imports = [ <home-manager/nixos> ];
  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.

  nix = {
    autoOptimiseStore = true;
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

  programs = {
    gnupg.agent = {
      enable = true;
      pinentryFlavor = lib.mkDefault "curses";
    };
    zsh = {
      enable = true;
      #autosuggestions.enable = true;
      #syntaxHighlighting.enable = true;
      enableCompletion = false;
    };
    git.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    pueue
    neofetch
    starship
    exa
    bat
    jq
    bottom
    yadm
    fzf
  ];
}
