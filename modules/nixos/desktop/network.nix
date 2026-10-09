{lib, ...}: {
  services.resolved.settings.Resolve = {
    DNSOverTLS = lib.mkDefault "yes";
    # Cloudflare 1.1.1.1 and Quad9 unfiltered (9.9.9.10). The #name is checked against the server certificate.
    DNS = lib.mkDefault [
      "1.1.1.1#one.one.one.one"
      "2606:4700:4700::1111#one.one.one.one"
      "9.9.9.10#dns10.quad9.net"
      "2620:fe::10#dns10.quad9.net"
    ];
    # Only used when no other DNS server is known; the secondary address of each provider.
    FallbackDNS = lib.mkDefault [
      "1.0.0.1#one.one.one.one"
      "2606:4700:4700::1001#one.one.one.one"
      "149.112.112.10#dns10.quad9.net"
      "2620:fe::fe:10#dns10.quad9.net"
    ];
  };

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
        # Keep DHCP DNS recorded (captive-browser reads it) but never use it for general lookups.
        networkConfig.DNSDefaultRoute = false;
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
        networkConfig.DNSDefaultRoute = false;
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
