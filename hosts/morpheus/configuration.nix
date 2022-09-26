{ config, pkgs, ... }:

{
  networking.hostName = "morpheus"; # Define your hostname.

  hardware.bluetooth.enable = true;

  services.ratbagd.enable = true;

  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "max";
      configurationLimit = 25;
    };
    timeout = 3;
    efi.canTouchEfiVariables = true;
  };

  systemd.services.hd-idle = {
    description = "Spin down disks";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 300";
    };
  };

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  modules.services.nebula = {
    enable = true;
    #nodeName = "morpheus";
  };

  modules = {
    programs = {
      gaming.enable = true;
    };
    desktop = {
      enable = true;
      supportDDC = true;
      environment = "sway";
      mainResolution = {
        width = 2560;
        height = 1080;
      };
    };
  };
  
  home-manager.users.lsanche.wayland.windowManager.sway.config = {
    output = {
      DP-1 = {
        adaptive_sync = "on";
        pos = "1600 0";
        mode = "2560x1440@144.000000Hz";
      };
      DP-2 = {
        pos = "0 300";
      };
    };

    workspaceOutputAssign = 
    let
        ws = space: display: { workspace = space; output = display; };
    in
    [
      (ws "1" "DP-1")
      (ws "2" "DP-1")
      (ws "3" "DP-1")
      (ws "4" "DP-1")
      (ws "5" "DP-1")
      (ws "6" "DP-2")
      (ws "7" "DP-2")
      (ws "8" "DP-2")
      (ws "9" "DP-2")
    ];
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
    piper
  ];

  system.stateVersion = "21.05"; # Did you read the comment?

}

