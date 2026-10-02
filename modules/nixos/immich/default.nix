# meta.description = "Immich photo library with a daily RAW/JPG stacking job"
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  disabledModules = ["services/web-apps/immich.nix"];
  imports = ["${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/immich.nix"];
  age.secrets.immich.file = ../../../secrets/${config.networking.hostName}/immich.age;

  services = {
    immich = {
      enable = true;
      package = pkgs.unstable.immich;
      mediaLocation = "/data/bigpool/immich/data";
    };
    localProxy.subDomains.immich = {
      extraConfig.proxyWebsockets = true;
    };
  };

  systemd = {
    services.immich-stack = {
      sandbox = 2;
      description = "Stacking Raw and JPG Photos in Immich";
      script = ''
        ${lib.getExe pkgs.immich-go} stack --server=http://localhost:${toString config.services.immich.port} --api-key="$IMMICH_API_KEY" --manage-raw-jpeg StackCoverJPG
      '';
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = config.age.secrets.immich.path;

        # Run as a transient unprivileged user with its own writable state dir
        # for immich-go's cache/logs (WorkingDirectory + HOME point at it, so
        # nothing needs to write outside the sandbox).
        DynamicUser = true;
        StateDirectory = "immich-stack";
        WorkingDirectory = "%S/immich-stack";
        Environment = "HOME=%S/immich-stack";

        # sandbox=2 isolates the network namespace, but this needs real loopback TCP to the local immich API.
        PrivateNetwork = false;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"];

        ProtectProc = "invisible";
        ProcSubset = "pid";
        SystemCallFilter = ["@system-service"];
        SystemCallErrorNumber = "EPERM";
      };
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
