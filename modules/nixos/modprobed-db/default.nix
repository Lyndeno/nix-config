# meta.description = "Records every kernel module ever loaded, for `make localmodconfig`"
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.modprobedDb;

  dbFile = "${cfg.stateDir}/modprobed.db";

  # The upstream script has no flags: everything comes from a config file it
  # locates via $XDG_CONFIG_HOME. Point that at a store directory holding a
  # generated config so the whole thing stays declarative and read-only.
  configDir = pkgs.writeTextDir "modprobed-db.conf" ''
    DBPATH="${cfg.stateDir}"
    COLORS=dark
    IGNORE=(${lib.concatStringsSep " " cfg.ignoredModules})
  '';

  # An empty database is the signature of the script's tools being unavailable:
  # it exits 0 and logs "New database created", so the unit looks healthy while
  # recording nothing. Left unchecked that is only noticed weeks later, when the
  # db is supposed to drive a kernel config. Fail loudly instead.
  assertNonEmpty = pkgs.writeShellScript "modprobed-db-assert-nonempty" ''
    if [ ! -s "${dbFile}" ]; then
      echo "modprobed-db produced an empty database at ${dbFile}" >&2
      echo "this usually means a helper binary is missing from the unit PATH" >&2
      exit 1
    fi
  '';

  # Without this the CLI on $PATH would fall back to a per-user config and
  # report on a database in ~/.config, not the one the timer maintains.
  modprobed-db = pkgs.symlinkJoin {
    name = "modprobed-db-system";
    paths = [pkgs.modprobed-db];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/modprobed-db --set XDG_CONFIG_HOME ${configDir}
    '';
  };
in {
  options.services.modprobedDb = {
    enable = lib.mkEnableOption ''
      periodic recording of loaded kernel modules into a cumulative database.

      `make localmodconfig` only sees the modules loaded at the instant it
      runs, which misses anything hotplugged, mounted, or started at some
      other time. This accumulates the union over weeks so the resulting
      config covers hardware and workloads that were not active during the
      build
    '';

    interval = lib.mkOption {
      type = lib.types.str;
      default = "15min";
      example = "6h";
      description = ''
        `OnUnitActiveSec=` for the timer. A module that is loaded and unloaded
        entirely within one interval is never recorded, so this is
        deliberately shorter than upstream's 6h default; the scan is only a
        read of /proc/modules and costs effectively nothing.
      '';
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/modprobed-db";
      description = ''
        Directory holding `modprobed.db`. The database is world-readable so it
        can be fed to a kernel build as an unprivileged user:

        `make LSMOD=${dbFile} localmodconfig`
      '';
    };

    dbPath = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = dbFile;
      description = ''
        Resolved path to the database, for referring to from a kernel build
        without restating the layout.
      '';
    };

    ignoredModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        # Out-of-tree modules have no Kconfig symbol in the kernel tree, so
        # localmodconfig cannot act on them. Recording them is harmless but
        # makes the db misleading when read by hand.
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
        "nvidia_uvm"
        "v4l2loopback"
        "vboxdrv"
        "vboxnetadp"
        "vboxnetflt"
        "vboxpci"
        # ZFS and its SPL dependencies, built out-of-tree against the kernel.
        "icp"
        "spl"
        "zavl"
        "zcommon"
        "zfs"
        "zlua"
        "znvpair"
        "zunicode"
        "zzstd"
      ];
      description = ''
        Module names excluded from the database. Matched as anchored regex
        alternatives against each name in /proc/modules.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [modprobed-db];

    systemd.services.modprobed-db = {
      description = "Record newly loaded kernel modules into the modprobed database";
      documentation = ["man:modprobed-db(8)"];

      # The script derives its home directory from $USER (falling back to
      # logname(1), which fails without a tty) and refuses to run if it cannot.
      # Nothing under it is actually used once XDG_CONFIG_HOME is set, but the
      # lookup still has to succeed, so pin it rather than depend on whether
      # systemd exported $USER for a root unit.
      environment = {
        USER = "root";
        XDG_CONFIG_HOME = configDir;
      };

      # The script has no `set -e`, so a missing tool does not stop it: it just
      # produces empty output and writes an empty database. Do not rely on
      # systemd's default PATH — list everything the script actually calls.
      path = [
        pkgs.coreutils
        pkgs.gawk
        pkgs.getent
        pkgs.gnugrep
        pkgs.gnused
        pkgs.kmod
      ];

      serviceConfig = {
        Type = "oneshot";
        # `storesilent` runs the db-creating check first, so the initial run
        # bootstraps the file itself; no seeding step is needed.
        ExecStart = "${modprobed-db}/bin/modprobed-db storesilent";
        ExecStartPost = assertNonEmpty;

        StateDirectory = "modprobed-db";
        StateDirectoryMode = "0755";

        # Scratch files are hardcoded to /tmp/.inmem and /tmp/.potential_new_db,
        # which is both a collision and a symlink-attack surface on a shared /tmp.
        PrivateTmp = true;

        # Reads /proc/modules and writes StateDirectory; needs nothing else.
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateNetwork = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_UNIX"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service" "~@privileged" "~@resources"];
      };
    };

    systemd.timers.modprobed-db = {
      description = "Periodically scan for newly loaded kernel modules";
      wantedBy = ["timers.target"];
      timerConfig = {
        # Catch the early-boot and initrd modules once userspace has settled,
        # then sample on the interval for anything hotplugged later.
        OnBootSec = "2min";
        OnUnitActiveSec = cfg.interval;
        Persistent = true;
      };
    };
  };
}
