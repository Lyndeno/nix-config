{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.ls.desktop;
in {
  config = mkIf ((cfg.environment == "i3") && cfg.enable) {
    programs.gnupg.agent.pinentryFlavor = "gnome3";
    programs.dconf.enable = true;
    services.xserver = {
      enable = true;
      windowManager.i3.enable = true;
      windowManager.i3.package = pkgs.i3-gaps;
      displayManager.lightdm = {
        enable = true;
      };
    };

    security = {
      pam.services = {
        login.u2fAuth = false;
        lightdm.u2fAuth = false;
        lightdm.enableGnomeKeyring = true;
      };
      polkit.enable = true;
    };
    services.gnome.gnome-keyring.enable = true;
    services.gvfs.enable = true;

    xdg.portal = {
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    programs = {
      seahorse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      gnome.nautilus
    ];
  };
}
