{
  flake,
  system,
  ...
}:
(flake.nixosConfigurations.trinity.extendModules {
  modules = [
    {
      nixpkgs.buildPlatform = system;
      nixpkgs.hostPlatform = "aarch64-linux";
    }
  ];
}).config.system.build.image
