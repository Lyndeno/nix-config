{
  flake,
  system,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;
in
  (flake.nixosConfigurations.trinity.extendModules {
    modules = [
      {
        nixpkgs.buildPlatform = system;
        nixpkgs.hostPlatform = "aarch64-linux";
      }
    ];
  }).config.system.build.sysupdate-package.overrideAttrs (_: _: {
    meta.platforms = lib.platforms.linux;
  })
