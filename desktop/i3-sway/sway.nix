{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.ls.desktop;
  fix-xwayland = pkgs.writeShellScript "fix-xwayland" ''
    PRIM_DISPLAY=$(${pkgs.xorg.xrandr}/bin/xrandr | ${pkgs.gnugrep}/bin/grep 2560x1440+ | ${pkgs.gawk}/bin/awk '{print $1}')

    ${pkgs.xorg.xrandr}/bin/xrandr --output $PRIM_DISPLAY --primary && ${pkgs.libnotify}/bin/notify-send " XWayland" "Primary X display set to $PRIM_DISPLAY"
  '';
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
        imv
        zathura
      ];

      home-manager.users.lsanche = let
        commands = import ./sway/commands.nix {inherit config pkgs lib;};
      in rec {
        services.udiskie.enable = true;
        services.wlsunset = {
          enable = true;
          latitude = "53.6";
          longitude = "-113.3";
        };

        programs.waybar =
          {
            enable = true;
            package = pkgs.waybar.override {withMediaPlayer = true;};
          }
          // import ./sway/waybar {
            inherit pkgs lib commands config;
            mediaplayerCmd = "${programs.waybar.package}/bin/waybar-mediaplayer.py";
          };
        wayland.windowManager.sway = with config.scheme.withHashtag; let
          wallpaper = with cfg.mainResolution; "${import ./wallpaper.nix {inherit config pkgs;} {inherit height width;}}";
          modifier = wayland.windowManager.sway.config.modifier;
        in {
          enable = true;
          wrapperFeatures.gtk = true;
          package = null;
          config =
            (import ./common.nix {
              inherit config commands pkgs lib wallpaper;
              thm = config.lib.stylix.colors;
              # TODO: We use this to access our set terminal packages. Pass through that instead
              homeCfg = config.home-manager.users.lsanche;
              extraKeybindings = {
                "print" = "exec --no-startup-id ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.wl-clipboard}/bin/wl-paste > ~/Pictures/$(${pkgs.busybox}/bin/date +'screenshot_%Y-%m-%d-%H%M%S.png')";
                "${modifier}+Shift+x" = "exec ${fix-xwayland}";
              };
              extraStartup = [
                {command = "dbus-update-activation-environment WAYLAND_DISPLAY";}
              ];
            })
            // {
              bars = [];
              window.commands = [
                {
                  criteria = {
                    title = "^Picture-in-Picture$";
                    app_id = "firefox";
                  };
                  command = "floating enable, move position 877 450, sticky enable";
                }
                {
                  criteria = {
                    title = "Firefox — Sharing Indicator";
                    app_id = "firefox";
                  };
                  command = "floating enable, move position 877 450";
                }
              ];
              #output."*" = { bg = "${wallpaper} fill"; };
              input = {
                "type:touchpad" = {
                  tap = "enabled";
                  natural_scroll = "enabled";
                  scroll_factor = "0.2";
                };
              };
            };
        };

        programs.mako = with config.scheme.withHashtag; {
          enable = true;
          anchor = "bottom-right";
          borderRadius = 5;
          borderSize = 2;
          defaultTimeout = 10000;
          groupBy = "summary";
          layer = "overlay";
        };
      };
    }
    (import ./sway/greetd.nix {inherit config pkgs lib;})
    (import ./sway/wob.nix {inherit config pkgs lib;})
    (import ./sway/swayidle.nix {inherit config pkgs lib;})
  ]);
}
