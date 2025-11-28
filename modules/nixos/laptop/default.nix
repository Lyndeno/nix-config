{pkgs, ...}: {
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=2h
  '';

  services = {
    upower.criticalPowerAction = "Hibernate";
    logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
    automatic-timezoned.enable = true;
    geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
  };

  environment.systemPackages = with pkgs; [
    gnome-network-displays
  ];
}
