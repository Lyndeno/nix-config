{ config, pkgs, ... }:

{
  networking.hostName = "morpheus"; # Define your hostname.

  hardware.bluetooth.enable = true;

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
      environment = "plasma";
    };
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  networking.networkmanager.enable = true;

  services = {
    plex = {
      enable = true;
      openFirewall = true;
      group = "media";
    };
    xserver.displayManager.gdm.autoSuspend = false;
    #borgbackup.jobs."borgbase" = {
    #  paths = [
    #    "/var/lib"
    #    "/srv"
    #    "/home"
    #    "/data/mirror/archive"
    #  ];
    #  exclude = [
    #    "/var/lib/systemd"
    #    "/var/lib/libvirt"
    #    "/var/lib/plex"

    #    "**/target"
    #    "/home/*/.local/share/Steam"
    #  ];
    #  repo = "n2ikk4w3@n2ikk4w3.repo.borgbase.com:repo";
    #  encryption = {
    #    mode = "repokey-blake2";
    #    passCommand = "cat /root/borg/pass_morpheus";
    #  };
    #  environment.BORG_RSH = "ssh -i /root/borg/ssh_key";
    #  compression = "auto,zstd,10";
    #  startAt = "daily";
    #};
  };
  
  # Enable CUPS to print documents.
  services.printing.enable = true;
  modules.printers.canon.pixma.mx860.enable = true;

  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    btrfs-progs
  ];

  system.stateVersion = "21.05"; # Did you read the comment?

}

