{
  network = {
    wait-online.enable = false;
    networks = {
      "10-ethernet" = {
        matchConfig.Type = "ether";
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 100;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 100;
        };
        routes = [
          {
            Gateway = "_dhcp4";
            InitialCongestionWindow = 30;
            InitialAdvertisedReceiveWindow = 30;
          }
        ];
      };
      "20-wifi" = {
        matchConfig.Type = "wlan";
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 600;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 600;
        };
      };
    };
  };
  services.borgbackup-job-borgbase.unitConfig.ConditionACPower = true;
}
