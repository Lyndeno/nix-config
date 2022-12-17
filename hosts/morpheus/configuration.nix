{ config, pkgs, lib, ... }:

{
  networking.hostName = "morpheus"; # Define your hostname.

  hardware.bluetooth.enable = true;

  services.ratbagd.enable = true;

  services.smartd = {
    enable = true;
    notifications.mail.sender = "morpheus@lyndeno.ca";
    notifications.mail.recipient = "lsanche@lyndeno.ca";
    notifications.mail.enable = true;
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "max";
      configurationLimit = 25;
    };
    timeout = 3;
    efi.canTouchEfiVariables = true;
  };

  #networking.nat = {
  #  enable = true;
  #  internalInterfaces = ["ve-+"];
  #  externalInterface = "br0";
  #  #enableIPv6 = true;
  #};

  networking = {
    bridges = {
      br0 = {
        interfaces = [ "enp7s0" ];
      };
    };
    interfaces = {
      br0 = {
        useDHCP = true;
        #ipv4.addresses = [{ address = "192.168.86.42"; prefixLength = 24; }];
      };
      enp7s0 = {
        useDHCP = true;
      };
    };
  };

  age.secrets = {
    ca_vancouver = {
      file = ../../secrets/ca_vancouver.age;
      path = "/var/lib/nixos-containers/torrents/ca_vancouver";
      symlink = false;
    };
    pia_pass = {
      file = ../../secrets/pia_pass.age;
      path = "/var/lib/nixos-containers/torrents/pia_pass";
      symlink = false;
    };
  };

  containers.torrents = {
    autoStart = true;
    privateNetwork = true;
    #hostAddress = "192.168.86.10";
    localAddress = "192.168.86.99";
    #hostAddress6 = "fc00::1";
    #localAddress6 = "fc00::2";
    enableTun = true;
    config = { config, pkgs, ... }: {
      services.transmission = {
        enable = true;
        openRPCPort = true;
        openPeerPorts = true;
        settings.rpc-bind-address = "0.0.0.0";
        settings.rpc-whitelist-enabled = false;
      };
      services.resolved.enable = true;
      networking = {
        hostName = "morpheus-transmission";
        interfaces."eth0".useDHCP = true;
        useHostResolvConf = false;
      };
      system.stateVersion = "22.11";

      #services.openvpn.servers = {
      #  vancouver = {
      #    config = '' config /ca_vancouver '';
      #    autoStart = true;
      #  };
      #};

      networking.firewall = {
        enable = true;
      };

      services.openssh.enable = true;

      #environment.etc."resolv.conf".text = "nameserver 8.8.8.8";
    };
  };

  systemd.services.hd-idle = {
    description = "Spin down disks";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 3600";
    };
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:Lyndeno/nix-config/master";
    allowReboot = true;
    dates = "Mon, 03:00";
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
        render_bit_depth = "10";
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

  age.secrets = {
    id_borgbase.file = ../../secrets/id_borgbase.age;
    pass_borgbase.file = ../../secrets/morpheus/pass_borgbase.age;

    id_trinity_borg.file = ../../secrets/morpheus/id_trinity_borg.age;
    pass_trinity_borg.file = ../../secrets/morpheus/pass_trinity_borg.age;
  };

  systemd.services.jellyfin.serviceConfig.PrivateDevices = lib.mkForce false;

  services = {
    plex = {
      enable = true;
      openFirewall = true;
      group = "media";
    };
    jellyfin = {
      enable = true;
      group = "media";
      openFirewall = true;
    };
    xserver.displayManager.gdm.autoSuspend = false;
    borgbackup.jobs."borgbase" = with config.age.secrets; {
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
        "/home/*/Downloads"
      ];
      repo = "n2ikk4w3@n2ikk4w3.repo.borgbase.com:repo";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${pass_borgbase.path}";
      };
      environment.BORG_RSH = "ssh -i ${id_borgbase.path}";
      compression = "auto,zstd,10";
      startAt = "hourly";
      prune = {
        keep = {
          within = "3d";
          daily = 14;
          weekly = 4;
          monthly = -1;
        };
      };
    };
    borgbackup.jobs."trinity" = with config.age.secrets; {
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
        "/home/*/Downloads"
      ];
      repo = "borg@trinity.matrix:.";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${pass_trinity_borg.path}";
      };
      environment.BORG_RSH = "ssh -i ${id_trinity_borg.path}";
      compression = "auto,zstd,10";
      startAt = "hourly";
      prune = {
        keep = {
          within = "3d";
          daily = 14;
          weekly = 4;
          monthly = -1;
        };
      };
    };
  };
  
  # Enable CUPS to print documents.
  services.printing.enable = true;
  modules.printers.canon.pixma.mx860.enable = true;

  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    piper
  ];

  system.stateVersion = "22.11"; # Did you read the comment?

}

