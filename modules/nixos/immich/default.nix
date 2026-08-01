{
  config,
  pkgs,
  lib,
  ...
}: {
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

        # This only needs to reach the local immich API over TCP.
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        SystemCallArchitectures = "native";
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
