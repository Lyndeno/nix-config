# meta.description = "Userspace Wireless Support"
{
  networking = {
    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          AddressRandomization = "network";
        };
      };
    };
  };

  programs.captive-browser = {
    enable = true;
    interface = "wlan0";
  };
}
