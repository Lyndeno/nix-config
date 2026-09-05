{
  inputs,
  flake,
  config,
  ...
}: {
  imports = with flake.nixosModules; [
    inputs.disko.nixosModules.default
    xps-9560
    common
    stylix
    syncthing
    virtualisation
    desktop
    niri
    secureboot
    laptop
    hydraCache
    modprobed-db
    borgmatic
    ./borgbackup
    ./disko.nix
  ];

  # Do not change. See `man configuration.nix` — pins stateful defaults to NixOS version at install time.
  system.stateVersion = "21.11";

  nixpkgs.hostPlatform = "x86_64-linux";

  # Accumulating toward a localmodconfig-derived kernel; the laptop's real
  # module set only appears once every dock, peripheral, and suspend has run.
  services.modprobedDb.enable = true;

  hostMeta = {
    description = "Development laptop; occasional gaming.";
    specs = ''
      - Dell XPS 15 9560 — CPU: Intel i7-7700HQ — RAM: 64 GB
      - Storage: 1 TB NVMe
      - LUKS-encrypted root, Secure Boot via lanzaboote
      - BorgBackup to trinity (AC power only)
    '';
  };

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

  nix = {
    buildMachines = [
      {
        hostName = "morpheus";
        protocol = "ssh-ng";
        systems = ["x86_64-linux" "aarch64-linux"];
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark" "gccarch-znver3" "gccarch-skylake"];
        maxJobs = 32;
        speedFactor = 4;
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUtKd29tOXdrY2N0MUVjQmlMZ2EyMmU0bEplUTJBaHpOeUNDR2dqcmVVZC8gcm9vdEBtb3JwaGV1cwo=";
        sshUser = "builder";
        sshKey = config.age.secrets.builder.path;
      }
    ];
    settings.builders-use-substitutes = true;
  };

  boot = {
    initrd = {
      systemd = {
        enable = true;
      };
    };
    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  networking.hostName = "neo";
}
