{
  plymouth.enable = true;

  consoleLogLevel = 3;
  kernelParams = [
    "quiet"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
  ];
}
