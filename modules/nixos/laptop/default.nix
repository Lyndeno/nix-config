# meta.description = "Laptop power management: suspend-then-hibernate, iwd, geolocated timezone"
{flake, ...}: _: {
  imports = [
    flake.nixosModules.wireless
  ];

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
}
