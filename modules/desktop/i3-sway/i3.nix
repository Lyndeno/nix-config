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
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    programs = {
      seahorse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      gnome.nautilus
    ];

    home-manager.users.lsanche = let
      swaylock-config = pkgs.callPackage ./swaylock.nix { thm = config.lib.stylix.colors; };
      commands = {
        lock = "${pkgs.swaylock}/bin/swaylock -C ${swaylock-config}";
        terminal = "${pkgs.alacritty}/bin/alacritty";
        menu = let
          themeArgs = with config.lib.stylix.colors.withHashtag; builtins.concatStringsSep " " [
            # Inspired from https://git.sr.ht/~h4n1/base16-bemenu_opts
            "--tb '${base01}'"
            "--nb '${base01}'"
            "--fb '${base01}'"
            "--hb '${base03}'"
            "--sb '${base03}'"
            "--hf '${base0A}'"
            "--sf '${base0B}'"
            "--tf '${base05}'"
            "--ff '${base05}'"
            "--nf '${base05}'"
            "--scb '${base01}'"
            "--scf '${base03}'"
          ];
        in "${pkgs.bemenu}/bin/bemenu-run -b -H 25 ${themeArgs} --fn 'CaskaydiaCove Nerd Font 12'";
      };
    in rec {
      xsession.windowManager.i3 = {
        enable = true;
        config = (import ./common.nix {
          inherit commands pkgs lib;
          wallpaper = with config.modules.desktop.mainResolution; "${import ./wallpaper.nix { inherit config pkgs; } { inherit height width; }}";
          thm = config.lib.stylix.colors;
          homeCfg = config.home-manager.users.lsanche;
        });
      };

    };
  };
}
