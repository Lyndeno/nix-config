{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.desktop;
in
{
  options = {
      modules = {
          desktop = {
              enable = mkOption {type = types.bool; default = false; };
          };
      };
  };

  config = mkIf cfg.enable {
    services.greetd = {
        enable = true;
        settings = {
        default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
            user = "greeter";
        };
        };
    };

    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    };

    programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
            swaylock
            swayidle
            wl-clipboard
            mako
            alacritty
			wofi
            waybar
        ];
    };

    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };


    environment.systemPackages = with pkgs; [
        firefox-wayland
    ];
  };
}
