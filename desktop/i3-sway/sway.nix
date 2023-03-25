{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.ls.desktop;
in {
  config = mkIf ((cfg.environment == "sway") && cfg.enable) (lib.mkMerge [
    {
      programs.gnupg.agent.pinentryFlavor = "gnome3";

      services.gnome.gnome-keyring.enable = true;
      services.gvfs.enable = true;

      xdg.portal = {
        wlr.enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
      };

      programs = {
        sway = {
          enable = true;
          wrapperFeatures.gtk = true;
          extraPackages = with pkgs; [
            swaylock
            swayidle
            wl-clipboard
            mako
            alacritty
            bemenu
            slurp
            grim
            acpi
          ];
        };
        seahorse.enable = true;
      };

      environment.systemPackages = with pkgs; [
        gnome.nautilus
      ];
    }
    (import ./greetd.nix {inherit config pkgs lib;})
  ]);
}
