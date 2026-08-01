# meta.description = "E-mails a report when a systemd unit enters the failed state"
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.failureNotify;

  # Default delivery: hand the full RFC5322 message to msmtp on stdin and let
  # it read the recipients from the headers (-t).
  defaultSendmail = "${lib.getExe pkgs.msmtp} -t";

  # Instanced handler: `notify-email@<failed-unit>` mails a short report about
  # the unit that failed. Triggered via OnFailure= on the units below.
  notifyScript = pkgs.writeShellScript "notify-email" ''
    set -eu
    unit="$1"
    ${cfg.sendmailCommand} <<EOF
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

    sendmailCommand = lib.mkOption {
      type = lib.types.str;
      default = defaultSendmail;
      defaultText = lib.literalExpression ''"''${lib.getExe pkgs.msmtp} -t"'';
      description = ''
        Command handed the full message on stdin. Defaults to msmtp; override
        it to deliver the message elsewhere (e.g. capture it to a file in a
        test).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        # Only the default delivery path needs msmtp.
        assertion = cfg.sendmailCommand != defaultSendmail || config.programs.msmtp.enable;
        message = "services.failureNotify requires programs.msmtp to send mail (or a custom sendmailCommand).";
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
