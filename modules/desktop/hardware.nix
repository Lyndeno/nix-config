{pkgs, lib, ...}:
{

  # Enable support for flashing Moonlander Mk I
  hardware.keyboard.zsa.enable = true;

  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"
  '';

  # Enable adb and udev rules to connect to Android devices
  programs.adb.enable = true;

  environment.systemPackages = with pkgs; [
    wally-cli # for moonlander
    brightnessctl # for brightness control
  ];
}
