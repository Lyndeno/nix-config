{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.desktop.gnome;
  deskCfg = config.modules.desktop;
in
{
  options = {
    modules = {
      desktop = {
        gnome = {
          enable = mkOption { type = types.bool; default = true; };
        };
      };
    };
  };

  config = mkIf (cfg.enable && deskCfg.enable) {
    programs.gnupg.agent.pinentryFlavor = "gnome3";
    services.xserver.desktopManager.gnome.enable = true;
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
      ( mkIf deskCfg.software.backup pika-backup )
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