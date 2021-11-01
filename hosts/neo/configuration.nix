# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  #imports =
  #  [ # Include the results of the hardware scan.
  #    ./hardware-configuration.nix
  #  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.zsh = {
	enable = true;
	enableCompletion = true;
	autosuggestions.enable = true;
	syntaxHighlighting.enable = true;
  };

  networking.hostName = "neo"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp2s0.useDHCP = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  networking.networkmanager.enable = true;


  programs.sway = {
	enable = true;
	wrapperFeatures.gtk = true;
	extraPackages = with pkgs; [
		swaylock
		swayidle
		wl-clipboard
		mako
		alacritty
		dmenu
    waybar
	];
  };

  services = {
	syncthing = {
		enable = true;
		user = "lsanche";
		dataDir = "/home/lsanche";
		configDir= "/home/lsanche/.config/syncthing";
	};
	# Must create .snapshots subvolume in root of snapshotted subvolume
	snapper = {
		configs = {
			home = {
				subvolume = "/home";
				extraConfig = ''
					ALLOW_USERS="lsanche"
					TIMELINE_CREATE=yes
					TIMELINE_CLEANUP=yes
				'';
				};
		};
	};
  };
  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    cups-bjnp
  ];

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.fstrim.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lsanche = {
    isNormalUser = true;
    description = "Lyndon Sanche <lsanche@lyndeno.ca>";
    home = "/home/lsanche";
    uid = 1000;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox-wayland
    libnotify
    pueue
    #texlive.combined.scheme-full
    #rustup
    git
    #gcc
    #clang
    gnupg
    pinentry-curses
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

