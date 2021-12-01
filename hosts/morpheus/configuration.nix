# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  networking.hostName = "morpheus"; # Define your hostname.

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.consoleMode = "max";

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  modules.desktop.enable = true;
  modules.pia-vpn.enable = true;
  modules.gaming.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #networking.interfaces.wlp2s0.useDHCP = true;

  networking.networkmanager.enable = true;

  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "/srv/plex";
    group = "media";
  };

  services = {
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
  
  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    cups-bjnp
  ];

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  services.fstrim.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #environment.systemPackages = with pkgs; [
  #];

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

