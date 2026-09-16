{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.lib.stylix) colors;
  inherit (config.stylix) opacity;

  # Hex alpha suffix for wob's popup, matching stylix's opacity.popups (0-1).
  wobOpacity = lib.fixedWidthString 2 "0" (
    lib.toHexString (builtins.floor (opacity.popups * 255 + 0.5))
  );

  wobBorderColor = colors.base05 + wobOpacity;
  wobBackgroundColor = colors.base00 + wobOpacity;
in {
  # stylix's own wob target doesn't yet support opacity; themed manually until it does.
  stylix.targets.wob.enable = false;

  assertions = [
    {
      assertion = lib.versionOlder lib.trivial.release "26.11";
      message = ''
        modules/home/wlroots/services.nix manually themes wob with opacity
        because stylix's release-26.05 wob target doesn't support it yet.
        nixpkgs is now ${lib.trivial.release}, so stylix's wob target has
        likely gained opacity support upstream: remove this manual
        workaround (wobOpacity/wobBorderColor/wobBackgroundColor and the
        `stylix.targets.wob.enable = false` line) and re-enable the target.
      '';
    }
  ];

  services = {
    cliphist = {
      enable = true;
      allowImages = true;
    };

    wlsunset = {
      enable = true;
      latitude = "53.6";
      longitude = "-113.9";
      temperature.night = 1500;
    };

    mako = {
      enable = true;
      settings = {
        default-timeout = 30 * 1000;
        border-radius = 12;
      };
    };

    swayidle = let
      lock = lib.getExe pkgs.lock-screen;
    in {
      enable = true;
      events.before-sleep = lock;
      timeouts = [
        {
          timeout = 5;
          command = lib.getExe pkgs.lock-screen-timeout;
        }
        {
          timeout = 300;
          command = lock;
        }
        {
          timeout = 305;
          command = lib.getExe pkgs.screen-timeout;
        }
        {
          timeout = 900;
          command = lib.getExe pkgs.sleep-on-battery;
        }
      ];
    };

    wob = {
      enable = true;
      settings."" = {
        anchor = "bottom";
        margin = 60;
        border_color = wobBorderColor;
        background_color = wobBackgroundColor;
        bar_color = colors.base0A;
        overflow_bar_color = colors.base08;
        overflow_background_color = wobBackgroundColor;
        overflow_border_color = wobBorderColor;
      };
    };

    kanshi = {
      enable = true;
      profiles = {
      };
      settings = let
        main_screen = "Sharp Corporation 0x1453 Unknown";
        zenscreen = "Unknown ASUS MB16AC J6LMTF097058";
        lg_gaming = "LG Electronics LG QHD 0x00012B23";
        small_dell = "Dell Inc. DELL P2014H J6HFT3B9AK7L";
      in [
        {
          profile = {
            name = "laptop_only";
            outputs = [
              {
                criteria = main_screen;
                scale = 1.0;
                position = "0,0";
              }
            ];
          };
        }
        {
          profile = {
            name = "with_zenscreen";
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
        }
        {
          profile = {
            name = "docked";
            outputs = [
              {
                criteria = main_screen;
                scale = 1.25;
                position = "384,0";
              }
              {
                mode = "2560x1440@99.946";
                criteria = lg_gaming;
                scale = 1.0;
                position = "1920,0";
              }
            ];
          };
        }
        {
          profile = {
            name = "docked_triple";
            outputs = [
              {
                criteria = main_screen;
                scale = 1.25;
                position = "384,0";
              }
              {
                mode = "2560x1440@74.971";
                criteria = lg_gaming;
                scale = 1.0;
                position = "1920,0";
              }
              {
                criteria = small_dell;
                scale = 1.00;
                position = "4480,150";
              }
            ];
          };
        }
        {
          profile = {
            name = "office_desktop";
            outputs = [
              {
                criteria = lg_gaming;
                scale = 1.0;
                position = "0,0";
                mode = "2560x1440@144.000";
              }
              {
                criteria = small_dell;
                scale = 1.0;
                position = "2560,370";
              }
            ];
          };
        }
      ];
    };
  };
}
