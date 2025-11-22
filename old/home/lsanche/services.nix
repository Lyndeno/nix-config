{
  osConfig,
  pkgs,
}: let
  isNiri = osConfig.modules.niri.enable;
in {
  spotifyd = {
    enable = osConfig.networking.hostName == "morpheus";
    settings = {
      global = {
        device_name = "morpheus";
        backend = "pulseaudio";
        bitrate = 320;
        volume_controller = "alsa_linear";
      };
    };
  };

  wlsunset = {
    enable = isNiri;
    latitude = "53.6";
    longitude = "-113.9";
    temperature.night = 1500;
  };

  mako = {
    enable = isNiri;
    settings = {
      default-timeout = 30 * 1000;
    };
  };

  swayidle = let
    lock = "${pkgs.swaylock}/bin/swaylock -fF";
    runInShell = name: cmd: "${pkgs.writeShellScript "${name}" ''${cmd}''}";
    screenTimeout = "${pkgs.niri}/bin/niri msg action power-off-monitors";
    pgrep = "${pkgs.procps}/bin/pgrep";
    cut = "${pkgs.coreutils-full}/bin/cut";
    systemctl = "${pkgs.systemd}/bin/systemctl";
    lockScreenTimeout = runInShell "swayidle-lockscreen-timeout" ''
      if ${pgrep} swaylock
      then
        ${screenTimeout}
      fi
    '';
    idleSleep = runInShell "swayidle-sleep-when-idle" ''
      BAT_STATUS=$(${pkgs.acpi}/bin/acpi -a | ${cut} -d" " -f3 | ${cut} -d- -f1)
      if [ "$BAT_STATUS" = "off" ]
      then
        ${systemctl} suspend-then-hibernate
      fi
    '';
  in {
    enable = isNiri;
    events = [
      {
        event = "before-sleep";
        command = lock;
      }
    ];
    timeouts = [
      {
        timeout = 5;
        command = lockScreenTimeout;
      }
      {
        timeout = 300;
        command = lock;
      }
      {
        timeout = 305;
        command = screenTimeout;
      }
      {
        timeout = 900;
        command = idleSleep;
      }
    ];
  };

  polkit-gnome.enable = isNiri;

  wob = {
    enable = isNiri;
    settings."" = {
      anchor = "bottom";
      margin = 60;
    };
  };

  kanshi = {
    enable = isNiri;
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
}
