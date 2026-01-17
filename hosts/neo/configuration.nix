{
  inputs,
  flake,
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

      id_trinity_borg.file = ../../secrets/neo/id_trinity_borg.age;
      pass_trinity_borg.file = ../../secrets/neo/pass_trinity_borg.age;
    };
  };

  boot = {
    swraid.enable = false;
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
