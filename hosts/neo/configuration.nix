{ config, lib, pkgs, ... }:

let
  info = import ./info.nix;
in {
  networking.hostName = info.hostname; # Define your hostname.


  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 25;
    timeout = 3;
    efi.canTouchEfiVariables = true;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  modules = {
    desktop.enable = true;
    desktop.environment = "sway";
    desktop.mainResolution = {
      height = 1080;
      width = 1920;
    };
  };

  modules.services.nebula = {
    enable = true;
    nodeName = "neo";
  };

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
    networkmanager.plugins = [
      pkgs.networkmanager-openvpn
    ];
  };

  age.secrets = {
    id_borgbase.file = ../../secrets/id_borgbase.age;
    pass_borgbase.file = ../../secrets/neo/pass_borgbase.age;

    id_trinity_borg.file = ../../secrets/neo/id_trinity_borg.age;
    pass_trinity_borg.file = ../../secrets/neo/pass_trinity_borg.age;
  };
  services = {
    logind.lidSwitch = "suspend-then-hibernate";
    power-profiles-daemon.enable = true;
    borgbackup.jobs."borgbase" = with config.age.secrets; {
      paths = [
        "/var/lib"
        "/srv"
        "/home"
      ];
      exclude = [
        "/var/lib/systemd"
        "/var/lib/libvirt"
        "/var/lib/plex"

        "**/target"
        "/home/*/.local/share/Steam"
        "/home/*/Downloads"
      ];
      repo = "f774k1bg@f774k1bg.repo.borgbase.com:repo";
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
    #borgbackup.jobs."omicron-local" = {
    #  paths = [
    #    "/var/lib"
    #    "/srv"
    #    "/home"
    #  ];
    #  exclude = [
    #    "/var/lib/systemd"
    #    "/var/lib/libvirt"
    #    "/var/lib/plex"

    #    "**/target"
    #    "/home/*/.local/share/Steam"
    #    "/home/*/Downloads"
    #  ];
    #  repo = "/data/omicron/borg/neo";
    #  encryption = {
    #    mode = "repokey-blake2";
    #    passCommand = "cat /root/borg/pass_omicron";
    #  };
    #  #environment.BORG_RSH = "ssh -i /root/borg/ssh_key";
    #  removableDevice = true;
    #  doInit = false;
    #  compression = "auto,zstd,10";
    #  startAt = [ ];
    #};
  };
  
  # Enable CUPS to print documents.
  services.printing.enable = true;
  modules.printers.canon.pixma.mx860.enable = true;

  services.fstrim.enable = true;

  home-manager.users.lsanche.wayland.windowManager.sway.config = let
      brightness = value: "${pkgs.brightnessctl}/bin/brightnessctl set ${value} | sed -En 's/.*\\(([0-9]+)%\\).*/\\1/p' > $XDG_RUNTIME_DIR/wob.sock";
  in{
      keybindings = lib.mkOptionDefault {
        # TODO: Figure out how to make this conditional on host
        "XF86MonBrightnessUp" = "exec ${brightness "+5%"}";
        "XF86MonBrightnessDown" = "exec ${brightness "5%-"}";
      };
    };

  home-manager.users.lsanche.services.kanshi = {
      enable = true;
      profiles = let
        main_screen = "eDP-1";
        zenscreen = "Unknown ASUS MB16AC J6LMTF097058";
      in {
        single = {
          outputs = [{
            criteria = main_screen;
            scale = 1.0;
            position = "0,0";
          }];
        };
        with_zenscreen = {
          outputs = [
            {
              criteria = main_screen;
              scale = 1.0;
              position = "0,0";
            }
            {
              criteria = zenscreen;
              scale = 1.0;
              position = "1920,0";
            }
          ];
        };
      };
    };

  environment.systemPackages = with pkgs; [
    libsmbios # For fan control
    transmission-qt
    virt-manager
  ];

  system.stateVersion = info.stateVersion; # Did you read the comment?

}

