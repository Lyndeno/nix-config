{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.ls.desktop;
in {
  config = mkIf ((cfg.environment == "gnome") && cfg.enable) {
    programs.gnupg.agent.pinentryFlavor = "gnome3";
    services.xserver = {
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      enable = true;
    };
    security.pam.services.gdm.u2fAuth = false;

    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-tour
        gnome-text-editor
      ])
      ++ (with pkgs.gnome; [
        gnome-music
        gedit
        epiphany
        gnome-characters
        gnome-maps
        gnome-font-viewer
        totem
      ]);

    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    services.fwupd.enable = true;

    environment.systemPackages = with pkgs;
      [
        gnome.gnome-tweaks
        (mkIf cfg.software.backup pika-backup)
        gnome-firmware
      ]
      ++ (with gnomeExtensions; [
        appindicator
        #dash-to-panel
        dash-to-dock
        tailscale-status
      ]);
    services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  };
}
