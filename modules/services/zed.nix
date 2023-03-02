{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.services.zed;
in {
  options.modules.services.zed = {
    enable = lib.mkEnableOption "ZFS ZED";
    email = {
      enable = lib.mkEnableOption "ZED email notifications" // {default = true;};
    };
    pushover = {
      enable = lib.mkEnableOption "ZED pushover notifications" // {default = true;};
    };
  };

  config = lib.mkIf cfg.enable {
    modules.services.msmtp.enable = cfg.email.enable;

    age.secrets.zed_pushover.file = ../../secrets/zed_pushover.age;
    age.secrets.zed_user.file = ../../secrets/zed_user.age;
    services.zfs.zed.settings = lib.mkMerge [
      {
        ZED_DEBUG_LOG = "/tmp/zed.debug.log";

        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = true;

        ZED_USE_ENCLOSURE_LEDS = true;
        ZED_SCRUB_AFTER_RESILVER = true;
      }
      (lib.mkIf cfg.email.enable {
        ZED_EMAIL_ADDR = ["lsanche@lyndeno.ca"];
        ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
        ZED_EMAIL_OPTS = "@ADDRESS@";
      })
      (lib.mkIf cfg.pushover.enable {
        ZED_PUSHOVER_TOKEN = "$(${pkgs.busybox}/bin/cat ${config.age.secrets.zed_pushover.path})";
        ZED_PUSHOVER_USER = "$(${pkgs.busybox}/bin/cat ${config.age.secrets.zed_user.path})";
      })
    ];

    services.zfs.zed.enableMail = false;
  };
}
