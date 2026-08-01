{
  systemd = {
    sleep.settings.Sleep = {
      HibernateDelaySec = "2h";
    };

    # Skip unattended nix maintenance while on battery; the timers will run
    # the next time the job fires on AC. (Borg already gates on AC per-host.)
    services = {
      nix-gc.unitConfig.ConditionACPower = true;
      nix-optimise.unitConfig.ConditionACPower = true;
    };
  };

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
