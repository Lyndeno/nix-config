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
}
