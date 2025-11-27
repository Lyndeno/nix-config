{
  programs.spotifyd = {
    enable = true;
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
