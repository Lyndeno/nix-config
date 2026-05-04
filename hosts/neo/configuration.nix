{
  inputs,
  flake,
  config,
  ...
}: {
  imports = with flake.nixosModules; [
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    xps-9560
    common
    virtualisation
    desktop
    niri
    secureboot
    laptop
    hydraCache
    attic-watch
    ./borgbackup/borgbase.nix
    ./disko.nix
  ];

  system.stateVersion = "21.11";

  nixpkgs.hostPlatform = "x86_64-linux";

  age = {
    secrets = {
      id_borgbase.file = ../../secrets/id_borgbase.age;
      pass_borgbase.file = ../../secrets/neo/pass_borgbase.age;
      builder.file = ../../secrets/builder.age;
      fastmail-jmap = {
        file = ../../secrets/fastmail_jmap.age;
        owner = "lsanche";
      };
    };
  };

  nix.buildMachines = [
    {
      hostName = "ssh-ng";
      protocol = "morpheus";
      systems = ["x86_64-linux" "aarch64-linux"];
      supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark" "gccarch-znver3" "gccarch-skylake"];
      maxJobs = 32;
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUtKd29tOXdrY2N0MUVjQmlMZ2EyMmU0bEplUTJBaHpOeUNDR2dqcmVVZC8gcm9vdEBtb3JwaGV1cwo=";
      sshUser = "builder";
      sshKey = config.age.secrets.builder.path;
    }
  ];

  boot = {
    initrd = {
      systemd = {
        enable = true;
      };
    };
    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  networking.hostName = "neo";

  systemd = {
    services.borgbackup-job-borgbase.unitConfig.ConditionACPower = true;
  };
}
