{lib, ...}: {
  systemd.network = {
    wait-online.enable = lib.mkDefault false;
    networks = {
      "05-virt" = {
        matchConfig.Name = "vnet*";
        linkConfig.Unmanaged = "yes";
      };
      "10-ethernet" = {
        matchConfig.Type = "ether";
        linkConfig.RequiredForOnline = lib.mkDefault false;
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 100;
          UseDomains = true;
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
        linkConfig.RequiredForOnline = lib.mkDefault false;
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 600;
          UseDomains = true;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 600;
        };
      };
    };
  };
}
