{
  inputs,
  flake,
  config,
  lib,
  ...
}: {
  imports = with flake.nixosModules; [
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    xps-9560
    common
    virtualisation
    desktop
    niri
    secureboot
    laptop
    hydraCache
    attic-watch
    ./borgbackup/borgbase.nix
    ./disko.nix
  ];

  system.stateVersion = "21.11";

  nixpkgs.hostPlatform = "x86_64-linux";

  services = {
    munin-node.enable = true;
    munin-cron = {
      enable = true;
      hosts = ''
        [${config.networking.hostName}]
        address localhost
      '';
    };
    nginx = {
      enable = true;
      virtualHosts = {
        "neo.lyndeno.ca" = {
          locations = {
            "/munin/static/" = {
              alias = "/var/www/munin/static/";
              extraConfig = ''
                expires modified +1w;
              '';
            };
            "/munin/" = {
              alias = "/var/www/munin/";
              extraConfig = ''
                expires modified +310s;
              '';
            };
            "/" = {
              extraConfig = ''
                rewrite ^/$ munin/ redirect; break;
              '';
            };
          };
        };
      };
    };
  };

  age = {
    secrets = {
      id_borgbase.file = ../../secrets/id_borgbase.age;
      pass_borgbase.file = ../../secrets/neo/pass_borgbase.age;

      id_trinity_borg.file = ../../secrets/neo/id_trinity_borg.age;
      pass_trinity_borg.file = ../../secrets/neo/pass_trinity_borg.age;

      pangolin.file = ../../secrets/neo/pangolin.age;
    };
  };

  services.cockpit.enable = true;
  services.cockpit.settings.WebService.Origins = lib.mkForce "http://localhost:9090 https://localhost:9090";

  services.newt = {
    enable = true;
    environmentFile = config.age.secrets.pangolin.path;
    settings.endpoint = "https://auth.lyndeno.ca";
  };

  boot = {
    swraid.enable = false;
    initrd = {
      systemd = {
        enable = true;
      };
    };
    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  networking.hostName = "neo";

  systemd = {
    services.borgbackup-job-borgbase.unitConfig.ConditionACPower = true;
  };
}
