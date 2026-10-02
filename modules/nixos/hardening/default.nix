# meta.description = "Systemd unit hardening"
{
  config,
  lib,
  ...
}: {
  imports = [
    ./option.nix
  ];

  systemd.services = {
    # tailscaled needs real networking/devices/capabilities, so sandbox=2 doesn't fit; hand-tuned here instead.
    # Guarded on the whole definition so hosts without Tailscale get no dangling tailscaled entry.
    tailscaled = lib.mkIf config.services.tailscale.enable {
      serviceConfig = {
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectKernelTunables = true; # ip_forward is set at boot via sysctl, not by tailscaled itself
        ProtectKernelLogs = true;
        ProtectClock = true;
        ProtectHostname = true;
        RestrictSUIDSGID = true;
        PrivateMounts = true;
        RemoveIPC = true;
        UMask = "0077";

        # Minimum capabilities to manage the TUN device, routes, netfilter rules, and serve MagicDNS on :53.
        CapabilityBoundingSet = ["CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_NET_BIND_SERVICE"];
        AmbientCapabilities = ["CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_NET_BIND_SERVICE"];
        NoNewPrivileges = true;

        DeviceAllow = ["/dev/net/tun rw"]; # PrivateDevices left at its default (false)

        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"]; # PrivateNetwork left at its default (false)

        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service"]; # ProtectKernelModules left at its default (false): tailscaled shells out to modprobe for its v6nat check

        LockPersonality = true;
        RestrictRealtime = true;
        RestrictNamespaces = true;
        MemoryDenyWriteExecute = true;
        # PrivateUsers left at its default (false): it would make CAP_NET_ADMIN/CAP_NET_RAW ineffective against the host netns
      };
    };

    # Upstream already hardens syncthing heavily; dataDir is a user's $HOME so ProtectHome is left off.
    syncthing = lib.mkIf config.services.syncthing.enable {
      serviceConfig = {
        SystemCallFilter = ["@system-service"];
        CapabilityBoundingSet = ["~CAP_SYSLOG"];
        UMask = "0077";
      };
    };

    # D-Bus-only clients (geoclue/timedated), no network/device/capability needs: sandbox=2 fits with no tuning.
    automatic-timezoned = lib.mkIf config.services.automatic-timezoned.enable {
      sandbox = 2;
      serviceConfig.SystemCallFilter = ["@system-service"];
    };
    automatic-timezoned-geoclue-agent = lib.mkIf config.services.automatic-timezoned.enable {
      sandbox = 2;
      serviceConfig.SystemCallFilter = ["@system-service"];
    };
  };
}
