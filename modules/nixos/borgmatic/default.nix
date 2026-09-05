# meta.description = "Shared borgmatic backup configuration"
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.hostBackup;

  postgresql = config.services.postgresql.package;

  # The upstream borgmatic module elevates DB dumps with `${pkgs.sudo}` — the
  # non-setuid store binary, which cannot switch users on NixOS. Run the dump
  # commands via systemd-run instead: borgmatic runs as root, so PID 1 spawns
  # them as the target user with no polkit/setuid involved, and --pipe wires
  # stdio through so borgmatic can stream and parse the output.
  withPgCommands = d: let
    runner =
      if d ? username && !(d ? password)
      then "${lib.getExe' pkgs.systemd "systemd-run"} --pipe --quiet --collect --uid=${d.username} --gid=${d.username} -- "
      else "";
  in
    {
      pg_dump_command =
        if d.name == "all" && (!(d ? format) || d.format == null)
        then "${runner}${postgresql}/bin/pg_dumpall"
        else "${runner}${postgresql}/bin/pg_dump";
      pg_restore_command = "${runner}${postgresql}/bin/pg_restore";
      psql_command = "${runner}${postgresql}/bin/psql";
    }
    // d;

  commonExcludes = [
    "/var/lib/systemd"
    "/var/lib/libvirt"
    "/var/lib/plex"

    "**/target"
    "**/.notmuch"
    "/home/*/.local"
    "/home/*/.cache"
    "/home/*/.mozilla"
    "/home/*/Downloads"
    "/home/*/.cargo"
  ];
in {
  options.services.hostBackup = {
    enable = lib.mkEnableOption "shared borgmatic backup";

    repository = lib.mkOption {
      type = lib.types.str;
      description = "Borg repository path (e.g. a Borgbase repo URL).";
    };

    passCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command that prints the repository passphrase on stdout.";
    };

    sshKey = lib.mkOption {
      type = lib.types.path;
      description = "SSH private key used to reach the repository.";
    };

    startAt = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "systemd OnCalendar expression for the backup timer.";
    };

    acPowerOnly = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Only run the backup while on AC power.";
    };

    healthchecksUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional Healthchecks ping URL for monitoring.";
    };

    extraSourceDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Host-specific paths to back up on top of the common set.";
    };

    extraExcludes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Host-specific exclude patterns on top of the common set.";
    };

    postgresqlDatabases = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
      default = [];
      description = "borgmatic postgresql_databases hook entries.";
    };

    checks = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
      default = [
        {
          name = "repository";
          frequency = "1 day";
        }
        {
          name = "archives";
          frequency = "2 weeks";
        }
        {
          name = "data";
          frequency = "1 month";
        }
      ];
      description = ''
        borgmatic consistency checks. Each needs a frequency, or it runs on
        every backup. Override per host: the "data" check reads/re-verifies
        every chunk (a full download for a remote repo), so drop it on
        bandwidth- or uptime-constrained machines like laptops.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.borgmatic = {
      enable = true;
      settings =
        {
          source_directories = ["/var/lib" "/srv" "/home"] ++ cfg.extraSourceDirectories;
          exclude_patterns = commonExcludes ++ cfg.extraExcludes;
          repositories = [
            {
              path = cfg.repository;
              label = "borgbase";
            }
          ];
          encryption_passcommand = cfg.passCommand;
          ssh_command = "ssh -i ${cfg.sshKey}";
          compression = "auto,zstd,10";
          keep_within = "3d";
          keep_daily = 14;
          keep_weekly = 4;
          keep_monthly = -1;
          inherit (cfg) checks;
          postgresql_databases = map withPgCommands cfg.postgresqlDatabases;
        }
        // lib.optionalAttrs (cfg.healthchecksUrl != null) {
          healthchecks.ping_url = cfg.healthchecksUrl;
        };
    };

    # borgmatic ships its own borgmatic.service/.timer; just steer them.
    systemd.timers.borgmatic.timerConfig.OnCalendar = lib.mkForce cfg.startAt;
    systemd.services.borgmatic.unitConfig =
      lib.mkIf cfg.acPowerOnly {ConditionACPower = true;};
  };
}
