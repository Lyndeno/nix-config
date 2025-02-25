{
  networkmanager = {
    enable = true;
    settings.connectivity = {
      uri = "http://google.com/generate_204";
      response = "";
    };
  };
  modemmanager.enable = false;
}
