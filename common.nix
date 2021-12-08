{ config, lib, pkgs, ...}:
{
  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.lsanche = {
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
        keys/neo.pub
        keys/morpheus.pub
      ];
      shell = pkgs.zsh;
    };
    groups = {
      lsanche = {};
      media = {}; # for torrents and plex
    };
  };

  services.openssh.enable = true;

  nix.autoOptimiseStore = true;
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";

  services = {
    syncthing = {
      enable = true;
      user = "lsanche";
      dataDir = "/home/lsanche";
      configDir= "/home/lsanche/.config/syncthing";
      openDefaultPorts = true;
    };
  };

  programs.gnupg.agent = {
	  enable = true;
	  #enableSSHSupport = true;
	  pinentryFlavor = lib.mkDefault "curses";
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.git.enable = true;

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
