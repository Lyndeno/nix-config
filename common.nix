{ config, pkgs, ...}:

{
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lsanche = {
    isNormalUser = true;
    description = "Lyndon Sanche <lsanche@lyndeno.ca>";
    home = "/home/lsanche";
    uid = 1000;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    initialPassword = "lsanche";
    openssh.authorizedKeys.keyFiles = [ keys/neo.pub ];
    shell = pkgs.zsh;
  };

  services.openssh.enable = true;

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
	  pinentryFlavor = "gnome3";
  };

  programs.zsh = {
	enable = true;
	autosuggestions.enable = true;
	syntaxHighlighting.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    pueue
    git
    gnupg
    pinentry-curses
    neofetch
    starship
    exa
    bat
    jq
    bottom
    yadm
    brightnessctl
    pulseaudio # for pactl
    xdg-utils
	fzf
  ];
}
