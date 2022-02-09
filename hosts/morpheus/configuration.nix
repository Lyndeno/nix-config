# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  networking.hostName = "morpheus"; # Define your hostname.

  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "max";
      configurationLimit = 25;
    };
    timeout = 3;
    efi.canTouchEfiVariables = true;
  };

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  modules = {
    programs = {
      gaming.enable = true;
    };
    services = {
    };
    desktop = {
      enable = true;
      supportDDC = true;
    };
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #networking.interfaces.wlp2s0.useDHCP = true;

  networking.networkmanager.enable = true;

  services = {
    plex = {
      enable = true;
      openFirewall = true;
      group = "media";
    };
    borgbackup.jobs."borgbase" = {
      paths = [
        "/var/lib"
        "/srv"
        "/home"
        "/data/mirror/archive"
      ];
      exclude = [
        "/var/lib/systemd"
        "/var/lib/libvirt"
        "/var/lib/plex"

        "**/target"
        "/home/*/.local/share/Steam"
      ];
      repo = "n2ikk4w3@n2ikk4w3.repo.borgbase.com:repo";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /root/borg/pass_morpheus";
      };
      environment.BORG_RSH = "ssh -i /root/borg/ssh_key";
      compression = "auto,zstd,10";
      startAt = "daily";
    };
  };
  
  # Enable CUPS to print documents.
  services.printing.enable = true;
  modules.printers.canon.pixma.mx860.enable = true;

  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    btrfs-progs
  ];

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

