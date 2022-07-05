{config, lib, pkgs, inputs, ...}:

with lib;

let
  cfg = config.modules.desktop;
in
{
  config = mkIf ((cfg.environment == "i3") && cfg.enable) {
    programs.gnupg.agent.pinentryFlavor = "gnome3";
    programs.dconf.enable = true;
    services.xserver = {
      enable = true;
      windowManager.i3.enable = true;
      #windowManager.i3.configFile = "$XDG_CONFIG_HOME" + i3/config;
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
      gtkUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    programs = {
      seahorse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      gnome.nautilus
    ];

    home-manager.users.lsanche = let
      swaylock-config = pkgs.callPackage ./swaylock.nix { thm = config.scheme; };
      commands = {
        lock = "${pkgs.swaylock}/bin/swaylock -C ${swaylock-config}";
      };
    in rec {
      xsession.windowManager.i3 = {
        enable = true;
        config = (import ./common.nix {
          inherit commands pkgs lib;
          wallpaper = with config.modules.desktop.mainResolution; "${import ./wallpaper.nix { inherit config pkgs; } { inherit height width; }}";
          thm = config.scheme;
          homeCfg = config.home-manager.users.lsanche;
        });
      };

    };
  };
}
