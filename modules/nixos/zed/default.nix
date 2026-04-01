{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
    inputs.self.nixosModules.msmtp
  ];
  age.secrets = {
    zed_pushover.file = ../../../secrets/zed_pushover.age;
    zed_user.file = ../../../secrets/zed_user.age;
  };
  services = {
    zfs.zed.settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";

      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = true;

      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;
      ZED_EMAIL_ADDR = ["lsanche@lyndeno.ca"];
      ZED_EMAIL_PROG = "${lib.getExe pkgs.msmtp}";
      ZED_EMAIL_OPTS = "@ADDRESS@";
      ZED_PUSHOVER_TOKEN = "$(${lib.getExe' pkgs.busybox "cat"} ${config.age.secrets.zed_pushover.path})";
      ZED_PUSHOVER_USER = "$(${lib.getExe' pkgs.busybox "cat"} ${config.age.secrets.zed_user.path})";
    };

    zfs.zed.enableMail = false;
  };
}
