{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.failureNotify;

  # Instanced handler: `notify-email@<failed-unit>` mails a short report about
  # the unit that failed. Triggered via OnFailure= on the units below.
  notifyScript = pkgs.writeShellScript "notify-email" ''
    set -eu
    unit="$1"
    ${lib.getExe pkgs.msmtp} -t <<EOF
    To: ${cfg.recipient}
    From: systemd <${cfg.from}>
    Subject: [${config.networking.hostName}] Unit failed: $unit

    The systemd unit "$unit" entered a failed state on ${config.networking.hostName} at $(date).

    ---- systemctl status ----
    $(${pkgs.systemd}/bin/systemctl status --full --lines=50 --no-pager "$unit" 2>&1 || true)

    ---- journal (last 50 lines) ----
    $(${pkgs.systemd}/bin/journalctl -u "$unit" -n 50 --no-pager 2>&1 || true)
    EOF
  '';
in {
  options.services.failureNotify = {
    enable = lib.mkEnableOption "e-mail notifications when systemd units fail";

    recipient = lib.mkOption {
      type = lib.types.str;
      default = "lsanche@lyndeno.ca";
      description = "Address that failure notifications are sent to.";
    };

    from = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}@system.${config.networking.domain}";
      description = "Envelope/From address for notifications.";
    };

    units = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["borgbackup-job-borgbase" "nix-gc"];
      description = ''
        Units to attach an `OnFailure=` handler to, named without the
        `.service` suffix. Each will trigger `notify-email@<unit>` when it
        enters the failed state. Names must match units that already exist on
        the host.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.programs.msmtp.enable;
        message = "services.failureNotify requires programs.msmtp to send mail.";
      }
    ];

    systemd.services = lib.mkMerge [
      {
        "notify-email@" = {
          description = "Send failure notification e-mail for %i";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${notifyScript} %i";
          };
        };
      }
      # Attach the handler to each target. `%n` expands to the full failing
      # unit name at runtime, so the report is about the right unit.
      (lib.genAttrs cfg.units (_: {
        unitConfig.OnFailure = "notify-email@%n.service";
      }))
    ];
  };
}
