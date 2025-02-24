{lib}: {
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  networking = {
    networkmanager = {
      enable = true;
      settings.connectivity = {
        uri = "http://google.com/generate_204";
        response = "";
      };
    };
  };
}
