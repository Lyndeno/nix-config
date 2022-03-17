{ config, lib, pkgs, ...}:

let
  inherit (lib)
    all types;
  inherit (lib.options)
    mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  cfg = config.services.avizo;
in {
  options.services.avizo = with lib.types; {
    enable = mkEnableOption "Avizo";

    package = mkOption {
      type = package;
      default = pkgs.avizo;
      defaultText = literalExpression "pkgs.avizo";
      description = ''
        Sample description
      '';
    };

    systemd.enable = mkEnableOption "Avizo systemd integration";
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package pkgs.pamixer ];

    systemd.user.services.avizo = mkIf cfg.systemd.enable {
      Unit = {
        Description = "Avizo";
        Documentation = "Avizo";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/avizo-service";
        Restart = "on-failure";
        KillSignal="SIGQUIT";
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
