# meta.description = "Systemd unit hardening"
{
  imports = [
    ./option.nix
  ];

  # tailscaled needs real networking (TUN device, raw sockets, netfilter/route
  # manipulation for subnet routers/exit nodes, DNS on :53), so the generic
  # `sandbox = 2` bundle (PrivateNetwork, empty CapabilityBoundingSet/
  # RestrictAddressFamilies, PrivateDevices) is not usable here. Hand-tuned
  # instead, kept here to track what's been loosened and why.
  #
  # Upstream's tailscaled systemd unit ships with no hardening at all, so
  # none of this overrides package defaults.
  systemd.services.tailscaled.serviceConfig = {
    # Filesystem: still fully confined, it only needs its state dir.
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    ProtectControlGroups = true;
    ProtectKernelTunables = true; # ip_forward is set at boot via boot.kernel.sysctl, not by tailscaled itself
    ProtectKernelLogs = true;
    ProtectClock = true;
    ProtectHostname = true;
    RestrictSUIDSGID = true;
    PrivateMounts = true;
    RemoveIPC = true;
    UMask = "0077";

    # Capabilities: only what's needed to manage the TUN device, routes and
    # netfilter rules, and to serve MagicDNS on :53. No further privilege
    # escalation.
    CapabilityBoundingSet = ["CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_NET_BIND_SERVICE"];
    AmbientCapabilities = ["CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_NET_BIND_SERVICE"];
    NoNewPrivileges = true;

    # Devices: needs /dev/net/tun to create the tailscale interface.
    # (PrivateDevices is left at its systemd default of false.)
    DeviceAllow = ["/dev/net/tun rw"];

    # Networking: must stay in the host's network namespace (PrivateNetwork
    # left at its systemd default of false) and keep the address families it
    # actually uses.
    RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"];

    # Kernel: module loading left alone (ProtectKernelModules at its systemd
    # default of false) — tailscaled shells out to modprobe for its v6nat
    # check (see `path = [ ... pkgs.kmod ... ]` in the upstream module).
    SystemCallArchitectures = "native";
    # Allow-list of normal service syscalls; everything else (module loading,
    # mount, reboot, swap, raw I/O, clock, etc.) is denied at the seccomp
    # level, on top of the capabilities already restricting most of it above.
    SystemCallFilter = ["@system-service"];

    # Misc
    LockPersonality = true;
    RestrictRealtime = true;
    RestrictNamespaces = true;
    MemoryDenyWriteExecute = true;
    # PrivateUsers is left at its systemd default of false: enabling it would
    # put tailscaled in a user namespace that doesn't own the host network
    # namespace, making CAP_NET_ADMIN/CAP_NET_RAW ineffective against it
    # (routes, netfilter rules, TUN) despite being in the bounding set.
  };
}
