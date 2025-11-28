{
  settings.Manager = {
    RuntimeWatchdogSec = "60s";
  };
  sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';
  services.garage = {
    serviceConfig = {
      User = "garage";
      Group = "garage";
      DynamicUser = false;
    };
  };
}
