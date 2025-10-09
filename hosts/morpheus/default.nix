{config}: {
  # Set your time zone.
  time.timeZone = "America/Edmonton";
  nix = {
    buildMachines = [
      {
        hostName = "localhost";
        protocol = null;
        systems = ["x86_64-linux" "aarch64-linux"];
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark" "gccarch-znver3" "gccarch-skylake"];
        maxJobs = 32;
      }
    ];
    settings = {
      allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
        "https://devimages-cdn.apple.com/"
      ];
      system-features = [
        "kvm"
        "nixos-test"
        "big-parallel"
        "benchmark"
        "gccarch-znver3"
        "gccarch-skylake"
      ];
    };
  };

  vpnNamespaces.vpn = {
    enable = true;
    wireguardConfigFile = config.age.secrets.vpn.path;
    accessibleFrom = [
      "192.168.1.0/24"
    ];
    portMappings = [
      {
        from = 9091;
        to = 9091;
      }
    ];
    openVPNPorts = [
      {
        port = 51413;
        protocol = "both";
      }
    ];
  };
}
