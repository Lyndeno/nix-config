{lib}: {
  useDHCP = false;
  networkmanager.enable = lib.mkForce false;
  wireless.iwd = {
    enable = true;
    settings = {
      General = {
        AddressRandomization = "network";
      };
    };
  };
}
