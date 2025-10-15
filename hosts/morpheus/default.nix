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

  nixarr = {
    enable = true;
    mediaDir = "/data/bigpool/media/nixarr";
    stateDir = "/data/bigpool/media/nixarr/.state/nixarr";

    vpn = {
      enable = true;
      wgConf = config.age.secrets.vpn.path;
    };

    transmission = {
      enable = true;
      vpn.enable = true;
      peerPort = 27607;
    };

    radarr.enable = true;
    sonarr.enable = true;
    prowlarr.enable = true;
  };
}
