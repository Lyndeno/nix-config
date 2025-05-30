{
  osConfig,
  pkgs,
}: let
  isNiri = osConfig.modules.niri.enable;
in {
  pueue = {
    enable = true;
    settings = {
      shared = {
        default_parallel_tasks = 1;
      };
    };
  };

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
        timeout = 300;
        command = lock;
      }
      {
        timeout = 305;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
      }
      {
        timeout = 900;
        command = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
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
