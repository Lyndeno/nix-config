{lib, ...}: let
  # Settings shared by the wired and wireless networks.
  common = {
    DHCP = "yes";
    linkConfig.RequiredForOnline = lib.mkDefault false;
    networkConfig = {
      # Keep DHCP DNS recorded (captive-browser reads it) but never use it for general lookups.
      DNSDefaultRoute = false;
      # Rotating temporary addresses for outgoing connections.
      IPv6PrivacyExtensions = true;
      # Opaque per-network link-local address instead of one derived from the MAC (EUI-64).
      IPv6LinkLocalAddressGenerationMode = "stable-privacy";
    };
    dhcpV4Config.UseDomains = true;
    # Opaque stable global address instead of one derived from the MAC (EUI-64).
    ipv6AcceptRAConfig.Token = "prefixstable";
  };
in {
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
      "60-ethernet" = lib.mkMerge [
        common
        {
          matchConfig.Type = "ether";
          dhcpV4Config.RouteMetric = 100;
          ipv6AcceptRAConfig.RouteMetric = 100;
          routes = [
            {
              Gateway = "_dhcp4";
              InitialCongestionWindow = 30;
              InitialAdvertisedReceiveWindow = 30;
            }
          ];
        }
      ];
      "80-wifi" = lib.mkMerge [
        common
        {
          matchConfig.Type = "wlan";
          # Keep addresses and routes across brief drops (AP roaming, resume).
          networkConfig.IgnoreCarrierLoss = "3s";
          dhcpV4Config.RouteMetric = 600;
          ipv6AcceptRAConfig.RouteMetric = 600;
        }
      ];
    };
  };
}
