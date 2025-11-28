{
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=2h
  '';

  services = {
    upower.criticalPowerAction = "Hibernate";
    logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
    automatic-timezoned.enable = true;
    geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
  };

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

  #environment.systemPackages = with pkgs; [
  # gnome-network-displays does not currently work with iwd
  #  gnome-network-displays
  #];
}
