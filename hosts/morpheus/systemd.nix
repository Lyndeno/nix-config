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
  network = {
    networks = {
      "10-enp7s0" = {
        name = "enp7s0";
        DHCP = "yes";
        routes = [
          {
            Gateway = "_dhcp4";
            InitialCongestionWindow = 30;
            InitialAdvertisedReceiveWindow = 30;
          }
        ];
      };
    };
  };
  services.transmission.vpnConfinement = {
    enable = true;
    vpnNamespace = "vpn";
  };
}
