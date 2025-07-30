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
}
