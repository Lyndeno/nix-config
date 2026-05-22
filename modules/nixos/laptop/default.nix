{lib, ...}: {
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "2h";
  };

  services = {
    upower.criticalPowerAction = "Hibernate";
    logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
    automatic-timezoned.enable = true;
    geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
  };

  services = {
    power-profiles-daemon.enable = lib.mkForce false;
    tlp = {
      enable = true;
      pd.enable = true;
      settings = {
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersave";
      };
    };
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
