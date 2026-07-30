{
  lib,
  pkgs,
  ...
}: {
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
      screenTimeout = pkgs.writeShellScriptBin "screen-timeout" "${lib.getExe pkgs.niri} msg action power-off-monitors";

      lockScreenTimeout = pkgs.writeShellApplication {
        name = "lock-screen-timeout";

        runtimeInputs = with pkgs; [
          procps
          niri
          screenTimeout
        ];

        text = ''
          if pgrep swaylock
          then
            screen-timeout
          fi
        '';
      };
    in {
      enable = true;
      events.before-sleep = lock;
      timeouts = [
        {
          timeout = 5;
          command = lib.getExe lockScreenTimeout;
        }
        {
          timeout = 300;
          command = lock;
        }
        {
          timeout = 305;
          command = lib.getExe screenTimeout;
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
