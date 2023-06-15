{
  pkgs,
  config,
}: {
  zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";

    ZED_NOTIFY_INTERVAL_SECS = 3600;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = true;
    ZED_SCRUB_AFTER_RESILVER = true;
    ZED_EMAIL_ADDR = ["lsanche@lyndeno.ca"];
    ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
    ZED_EMAIL_OPTS = "@ADDRESS@";
    ZED_PUSHOVER_TOKEN = "$(${pkgs.busybox}/bin/cat ${config.age.secrets.zed_pushover.path})";
    ZED_PUSHOVER_USER = "$(${pkgs.busybox}/bin/cat ${config.age.secrets.zed_user.path})";
  };

  zfs.zed.enableMail = false;
}
