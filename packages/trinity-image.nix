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
}).config.system.build.image.overrideAttrs (_: _: {
  meta.platforms = ["x86_64-linux"];
})
