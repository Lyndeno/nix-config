{
  pkgs,
  lib,
  ...
}: {
  # Enable support for flashing Moonlander Mk I
  hardware.keyboard.zsa.enable = true;

  # Enable adb and udev rules to connect to Android devices
  programs.adb.enable = true;

  environment.systemPackages = with pkgs; [
    wally-cli # for moonlander
    brightnessctl # for brightness control
  ];
}
