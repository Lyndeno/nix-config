{
  config,
  pkgs,
  lib,
  ...
}: {
  hardware.bluetooth.enable = true;
  boot.initrd.systemd.enable = true;
  boot.plymouth.enable = true;
  modules.services.vm.enable = true;

  services.smartd = {
    enable = true;
    notifications.mail.sender = "morpheus@lyndeno.ca";
    notifications.mail.recipient = "lsanche@lyndeno.ca";
    notifications.mail.enable = true;
  };

  boot.loader = {
    timeout = 3;
    efi.canTouchEfiVariables = true;
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux" "i686-linux"];

  systemd.services.hd-idle = {
    description = "Spin down disks";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 3600";
    };
  };

  #system.autoUpgrade = {
  #  enable = true;
  #  flake = "github:Lyndeno/nix-config/master";
  #  allowReboot = true;
  #  dates = "03:00";
  #  rebootWindow = {
  #    lower = "02:00";
  #    upper = "05:00";
  #  };
  #};

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  modules = {
    programs = {
      gaming.enable = true;
    };
  };

  ls = {
    desktop = {
      enable = true;
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

    workspaceOutputAssign = let
      ws = space: display: {
        workspace = space;
        output = display;
      };
    in [
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

  networking.networkmanager.enable = true;

  age.secrets = {
    id_borgbase.file = ../../secrets/id_borgbase.age;
    pass_borgbase.file = ../../secrets/morpheus/pass_borgbase.age;

    id_trinity_borg.file = ../../secrets/morpheus/id_trinity_borg.age;
    pass_trinity_borg.file = ../../secrets/morpheus/pass_trinity_borg.age;
  };

  systemd.services.jellyfin.serviceConfig.PrivateDevices = lib.mkForce false;

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';

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
        "/data/bigpool/archive"
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
      #preHook = ''
      #  echo "save-off" > /run/minecraft-server.stdin
      #  echo "say Saving" > /run/minecraft-server.stdin
      #  echo "save-all" > /run/minecraft-server.stdin
      #  sleep 5
      #  echo "say Backing Up" > /run/minecraft-server.stdin
      #'';
      #postHook = ''
      #  echo "save-on" > /run/minecraft-server.stdin
      #'';
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
        "/data/bigpool/archive"
      ];
      exclude = [
        "/var/lib/systemd"
        "/var/lib/libvirt"
        "/var/lib/plex"

        "**/target"
        "/home/*/.local/share/Steam"
        "/home/*/Downloads"
      ];
      repo = "borg@trinity:.";
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
    gamescope
    sbctl
  ];

  services.hardware.bolt.enable = false;
  services.power-profiles-daemon.enable = false;
}
