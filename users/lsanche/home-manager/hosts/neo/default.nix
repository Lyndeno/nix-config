{ config, lib, pkgs, ...}:
{
    wayland.windowManager.sway.config = {
      keybindings = lib.mkOptionDefault {
        # TODO: Figure out how to make this conditional on host
        "XF86MonBrightnessUp" = "exec ${pkgs.avizo}/bin/lightctl up 2";
        "XF86MonBrightnessDown" = "exec ${pkgs.avizo}/bin/lightctl down 2";
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
