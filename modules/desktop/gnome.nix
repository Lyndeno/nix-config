{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.desktop;
in
{
  config = mkIf ((cfg.environment == "gnome") && cfg.enable) {
    programs.gnupg.agent.pinentryFlavor = "gnome3";
    services.xserver = {
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
    };
    security.pam.services.gdm.u2fAuth = false;

    environment.gnome.excludePackages = (with pkgs; [
      gnome-tour
    ]) ++ (with pkgs.gnome; [
      gnome-music
      gedit
      epiphany
      gnome-characters
    ]);

    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
      ( mkIf cfg.software.backup pika-backup )
      fractal
      spot
    ] ++ (with gnomeExtensions; [
      appindicator
      dash-to-panel
      dash-to-dock
    ]);
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  };
}