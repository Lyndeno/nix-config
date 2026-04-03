{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age.secrets.immich.file = ../../../secrets/${config.networking.hostName}/immich.age;

  services = {
    immich = {
      enable = true;
      mediaLocation = "/data/bigpool/immich/data";
    };
    localProxy.subDomains.immich = {
      extraConfig.proxyWebsockets = true;
    };
  };

  systemd = {
    services.immich-stack = {
      serviceConfig = {
        EnvironmentFile = config.age.secrets.immich.path;
      };
      description = "Stacking Raw and JPG Photos in Immich";
      script = ''
        ${lib.getExe pkgs.immich-go} stack --server=http://localhost:${toString config.services.immich.port} --api-key="$IMMICH_API_KEY" --manage-raw-jpeg StackCoverJPG
      '';
    };
    timers.immich-stack = {
      wantedBy = ["timers.target"];
      description = "Stack RAW and JPG Photos in Immich Daily";
      timerConfig = {
        OnCalendar = "daily";
      };
    };
  };
}
