{osConfig}: {
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
    enable = true;
    latitude = "53.6";
    longitude = "-113.9";
  };

  mako = {
    enable = true;
  };

  swayosd = {
    enable = true;
  };
}
