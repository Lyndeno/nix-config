{ config, lib, pkgs, ...}:
{
  wayland.windowManager.sway.config = let
      brightness = value: "${pkgs.brightnessctl}/bin/brightnessctl set ${value} | sed -En 's/.*\\(([0-9]+)%\\).*/\\1/p' > $XDG_RUNTIME_DIR/wob.sock";
  in{
      keybindings = lib.mkOptionDefault {
        # TODO: Figure out how to make this conditional on host
        "XF86MonBrightnessUp" = "exec ${brightness "+5%"}";
        "XF86MonBrightnessDown" = "exec ${brightness "5%-"}";
      };
    };

    services.kanshi = {
      enable = true;
      profiles = let
        main_screen = "eDP-1";
        zenscreen = "Unknown ASUS MB16AC J6LMTF097058";
      in {
        single = {
          outputs = [{
            criteria = main_screen;
            scale = 1.0;
            position = "0,0";
          }];
        };
        with_zenscreen = {
          outputs = [
            {
              criteria = main_screen;
              scale = 1.0;
              position = "0,0";
            }
            {
              criteria = zenscreen;
              scale = 1.0;
              position = "1920,0";
            }
          ];
        };
      };
    };
}
