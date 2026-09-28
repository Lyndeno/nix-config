{
  inputs,
  flake,
  config,
  pkgs,
  lib,
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

    # Trimmed via localmodconfig from hosts/neo/modprobed.db; regenerate with
    # `install -m 644 "$(nix build --no-link --print-out-paths .#neo-kernel-config)" hosts/neo/kernel.config`
    # after a kernel bump or new hardware, keeping packages/neo-kernel-config.nix's
    # `pkgs.linuxPackages.kernel` pin in sync with the base kernel below.
    #
    # Must go through linuxManualConfig rather than `linuxPackages.kernel.override
    # { configfile = ...; }`: the top-level kernel package's `.override` targets
    # generic.nix's outer function, which has a catch-all `...` and silently drops
    # `configfile` (it's only a `let`-binding there, not a real parameter). Only
    # build.nix's function (what linuxManualConfig calls) actually takes it.
    kernelPackages = let
      kernel = pkgs.linuxPackages.kernel;
    in
      pkgs.linuxPackagesFor (pkgs.linuxManualConfig {
        inherit (kernel) version modDirVersion src kernelPatches features;
        configfile = ./kernel.config;
      });

    # NixOS's `boot.initrd.includeDefaultModules` (on by default) and its LUKS
    # initrd support both inject generic "just in case" module lists — legacy
    # PATA/SATA chipsets, USB 1.1/2.0 host controllers, vendor-specific HID
    # quirks, and alternate LUKS cipher/mode fallbacks (blowfish, serpent,
    # twofish, generic xts/lrw, crc32c) — that don't exist in the
    # localmodconfig-trimmed kernel above. Verified each entry with a real
    # `modprobe --dry-run` dependency resolution against the actual built
    # modules tree (not just grepping for a matching filename, since e.g.
    # `aes`/`autofs` resolve fine despite their .ko files being named
    # aes_generic/autofs4). The dropped crypto entries are all software
    # fallbacks: this LUKS volume uses aes-xts-plain64 (cryptsetup's
    # default), which aesni_intel (present, loaded per modprobed.db)
    # provides as a single fused, hardware-accelerated implementation
    # without needing the separate generic xts/aes templates.
    #
    # usb_storage and mmc_block are real capabilities (re-enabled in
    # packages/neo-kernel-config.nix), not dead entries, so they're
    # deliberately left off this list.
    initrd.availableKernelModules = lib.genAttrs [
      "ata_piix"
      "sata_nv"
      "sata_via"
      "sata_sis"
      "sata_uli"
      "pata_marvell"
      "sr_mod"
      "uhci_hcd"
      "ehci_hcd"
      "ehci_pci"
      "ohci_hcd"
      "ohci_pci"
      "hid_lenovo"
      "hid_apple"
      "hid_roccat"
      "hid_logitech_hidpp"
      "hid_logitech_dj"
      "hid_microsoft"
      "hid_cherry"
      "hid_corsair"
      "pcips2"
      "blowfish"
      "crc32c"
      "lrw"
      "serpent"
      "twofish"
      "xts"
    ] (_: lib.mkForce false);
  };

  networking.hostName = "neo";
}
