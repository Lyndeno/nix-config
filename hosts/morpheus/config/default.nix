{
  # Set your time zone.
  time.timeZone = "America/Edmonton";
  nix.buildMachines = [
    {
      hostName = "localhost";
      protocol = null;
      systems = ["x86_64-linux" "aarch64-linux"];
      supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
      maxJobs = 32;
    }
  ];
  nix.settings.allowed-uris = [
    "github:"
    "git+https://github.com/"
    "git+ssh://github.com/"
    "https://devimages-cdn.apple.com/"
  ];
}
