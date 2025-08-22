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
}
