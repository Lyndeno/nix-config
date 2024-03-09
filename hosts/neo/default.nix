{
  lib,
  pkgs,
}: {
  # Set your time zone.
  time.timeZone = "America/Edmonton";
  users.users.lsanche.createHome = true;
  programs.dconf.enable = true;

  security.tpm2.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  networking = {
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    libsmbios # For fan control
    sbctl
    gnome-network-displays
  ];
}
