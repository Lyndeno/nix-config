{
  description = "Lyndon's NixOS setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "nixos-hardware/master";
  };
  
  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    lib = nixpkgs.lib;

    commonModules = [
      home-manager.nixosModules.home-manager
      ./common.nix
      ./users
      ./modules
    ];

  in {
    nixosConfigurations = {
      neo = lib.nixosSystem { 
        inherit system pkgs;

        modules = commonModules ++ [
          ./hosts/neo
          nixos-hardware.nixosModules.dell-xps-15-9560-intel
          nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
        ];
      };

      morpheus = lib.nixosSystem {
        inherit system pkgs;

        modules = commonModules ++ [
          ./hosts/morpheus
        ];
      };

      oracle = lib.nixosSystem {
        inherit system pkgs;

        modules = commonModules ++ [
          ./hosts/oracle
        ];
      };

      vm = lib.nixosSystem {
        inherit system pkgs;

        modules = commonModules ++ [
          ./hosts/vm
        ];
      };
    };
  };
}
