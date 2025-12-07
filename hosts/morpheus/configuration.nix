{
  config,
  pkgs,
  inputs,
  flake,
  lib,
  ...
}: {
  imports = with inputs.nixos-hardware.nixosModules; [
    common-gpu-amd
    common-cpu-amd
    common-cpu-amd-pstate
    common-pc-ssd
    inputs.nixarr.nixosModules.default
    inputs.disko.nixosModules.default
    flake.nixosModules.common
    flake.nixosModules.virtualisation
    flake.nixosModules.zed
    flake.nixosModules.desktop
    flake.nixosModules.niri
    flake.nixosModules.secureboot
    ./disko.nix
    ./borgbackup/borgbase.nix
  ];
  # Set your time zone.
  time.timeZone = "America/Edmonton";
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "morpheus";
  nix = {
    buildMachines = [
      {
        hostName = "localhost";
        protocol = null;
        systems = ["x86_64-linux" "aarch64-linux"];
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark" "gccarch-znver3" "gccarch-skylake"];
        maxJobs = 32;
      }
    ];
    settings = {
      allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
        "https://devimages-cdn.apple.com/"
      ];
      system-features = [
        "kvm"
        "nixos-test"
        "big-parallel"
        "benchmark"
        "gccarch-znver3"
        "gccarch-skylake"
      ];
    };
  };

  systemd = {
    settings.Manager = {
      RuntimeWatchdogSec = "60s";
    };
    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
    '';
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "lsanche@lyndeno.ca";
      dnsProvider = "acme-dns";
      environmentFile = pkgs.writeText "acme-env" ''
        ACME_DNS_API_BASE=http://oracle:8080
        ACME_DNS_STORAGE_PATH=/var/lib/acme/.lego-acme-dns-accounts.json
      '';
    };
  };

  system.stateVersion = "23.05";

  environment.systemPackages = [pkgs.brasero];

  networking.hostId = "a5d4421d";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixroot";
      fsType = "xfs";
    };

    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
  };

  age = {
    secrets = {
      id_borgbase.file = ../../secrets/id_borgbase.age;
      pass_borgbase.file = ../../secrets/morpheus/pass_borgbase.age;
      vpn.file = ../../secrets/vpn.age;

      id_trinity_borg.file = ../../secrets/morpheus/id_trinity_borg.age;
      pass_trinity_borg.file = ../../secrets/morpheus/pass_trinity_borg.age;

      #webdav = {
      #  file = morpheus.webdav;
      #  owner = config.services.webdav-server-rs.user;
      #  inherit (config.services.webdav-server-rs) group;
      #};
      firefly-id = {
        file = ../../secrets/morpheus/firefly_id.age;
        owner = config.services.firefly-iii.user;
        inherit (config.services.firefly-iii) group;
      };
      attic-token.file = ../../secrets/morpheus/attic_token.age;
    };
  };

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux"];
    kernelModules = ["kvm-amd" "jc42" "nct6775" "ddcci" "sg"];
    swraid.enable = false;
    initrd = {
      systemd.enable = true;

      luks.devices."cryptroot" = {
        device = "/dev/disk/by-label/nixcrypt";
        bypassWorkqueues = true;
        allowDiscards = true;
      };

      availableKernelModules = ["nvme" "mpt3sas" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
    };
    supportedFilesystems = ["zfs"];
    zfs.extraPools = ["bigpool"];
  };

  nixarr = {
    enable = true;
    mediaDir = "/data/bigpool/media/nixarr";
    stateDir = "/data/bigpool/media/nixarr/.state/nixarr";

    vpn = {
      enable = true;
      wgConf = config.age.secrets.vpn.path;
    };

    transmission = {
      enable = true;
      vpn.enable = true;
      peerPort = 27607;
      extraSettings = {
        idle-seeding-limit = "600";
        idle-seeding-limit-enabled = true;
        ratio-limit = "3.0";
        ratio-limit-enabled = true;
      };
    };

    radarr.enable = true;
    sonarr.enable = true;
    prowlarr.enable = true;
  };

  services = {
    atticd = {
      #enable = true;
      environmentFile = config.age.secrets.attic-token.path;
      settings = {
        database = {
          url = "postgresql:///atticd?host=/run/postgresql";
        };
        storage = {
          type = "s3";
          region = "garage";
          bucket = "attic";
          endpoint = "http://morpheus:3900";
        };
      };
    };
    firefly-iii = let
      ff-user = config.services.firefly-iii.user;
    in {
      enable = true;
      virtualHost = "firefly.lyndeno.ca";
      enableNginx = true;
      settings = {
        DB_USERNAME = ff-user;
        DB_CONNECTION = "pgsql";
        DB_DATABASE = ff-user;
        APP_KEY_FILE = config.age.secrets.firefly-id.path;
      };
    };
    home-assistant = {
      enable = true;
      extraComponents = [
        "esphome"
        "met"
        "radio_browser"
        "cast"
        "thread"
        "ibeacon"
        "upnp"
        "google_translate"
        "tplink"
        "plex"
        "spotify"
        "webostv"
        "vesync"
        "tuya"
        "fitbit"
      ];
      config = {
        default_config = {};
      };
    };
    hydra = {
      enable = true;
      hydraURL = "https://hydra.lyndeno.ca";
      notificationSender = "hydra@morpheus";
      useSubstitutes = true;
    };
    immich = {
      enable = true;
      mediaLocation = "/data/bigpool/immich/data";
      port = 2283;
      openFirewall = true;
      host = "0.0.0.0";
      database.enableVectors = false;
    };
    logind.settings.Login.HandlePowerKey = "ignore";
    nginx = {
      enable = true;
      clientMaxBodySize = "50000M";
      proxyTimeout = "600s";

      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = lib.mkForce false;
      recommendedOptimisation = lib.mkForce false;

      virtualHosts = {
        "paperless.lyndeno.ca" = {
          enableACME = true;
          acmeRoot = null;
          forceSSL = true;

          locations."/" = {
            proxyPass = "http://localhost:${builtins.toString config.services.paperless.port}";

            proxyWebsockets = true;
            extraConfig = ''
              add_header Referrer-Policy "strict-origin-when-cross-origin";
            '';
          };
        };
        "immich.lyndeno.ca" = {
          enableACME = true;
          acmeRoot = null;
          forceSSL = true;

          locations."/" = {
            proxyPass = "http://localhost:${builtins.toString config.services.immich.port}";

            proxyWebsockets = true;
          };
        };
        "cache.lyndeno.ca" = {
          enableACME = true;
          acmeRoot = null;
          forceSSL = true;

          locations."/".extraConfig = ''
            proxy_pass http://localhost:8080;
          '';
        };
        "hydra.lyndeno.ca" = {
          enableACME = true;
          acmeRoot = null;
          forceSSL = true;

          locations."/".extraConfig = ''
            proxy_pass http://localhost:3000;
            proxy_set_header Host $host;
            proxy_redirect http:// https://;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
          '';
        };
        "${config.services.firefly-iii.virtualHost}" = {
          enableACME = true;
          acmeRoot = null;
          forceSSL = true;
        };
      };
    };
    ollama = {
      enable = true;
      acceleration = "rocm";
      rocmOverrideGfx = "10.3.0";
      openFirewall = true;
      host = "0.0.0.0";
    };
    open-webui = {
      enable = true;
      openFirewall = true;
      port = 8082;
      host = "0.0.0.0";
      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
        # Disable authentication
        WEBUI_AUTH = "False";
      };
    };
    paperless = {
      enable = true;
      database.createLocally = true;
      settings.PAPERLESS_URL = "https://paperless.lyndeno.ca";
    };
    plex = {
      enable = true;
      openFirewall = true;
      group = "media";
    };
    postgresql = let
      ff-user = config.services.firefly-iii.user;
      atticd-user = config.services.atticd.user;
    in {
      enable = true;
      ensureDatabases = [ff-user atticd-user];
      package = pkgs.postgresql_16;
      ensureUsers = [
        {
          name = ff-user;
          ensureDBOwnership = true;
        }
        {
          name = atticd-user;
          ensureDBOwnership = true;
        }
      ];
    };
    postgresqlBackup.enable = true;
    smartd = {
      enable = true;
      notifications.mail = {
        sender = "morpheus@lyndeno.ca";
        recipient = "lsanche@lyndeno.ca";
        enable = true;
      };
      # Short self test every week at 2AM
      # Long self test every month on the 5th at 4AM
      #defaults.monitored = "-a -o on -s (S/../../7/02|L/../05/../04)";
    };
    tailscale.useRoutingFeatures = "both";
    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };
  };

  systemd.network.networks."10-ethernet".matchConfig.Name = "enp7s0";
}
