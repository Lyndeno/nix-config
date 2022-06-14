{
  description = "Lyndon's NixOS setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "nixos-hardware/master";
    cfetch = {
      url = github:Lyndeno/cfetch/master;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, home-manager, nixos-hardware, cfetch, ... }:
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
      ({config, ...}: {
        environment.systemPackages = [ cfetch.packages.${system}.default ];
      })
    ];

    mkSystem = extraModules: lib.nixosSystem {
      inherit system pkgs;
      modules = commonModules ++ extraModules;
    };

  in {
    nixosConfigurations = {
      neo = with nixos-hardware.nixosModules; mkSystem [
          ./hosts/neo
          dell-xps-15-9560-intel
          common-cpu-intel-kaby-lake
      ];

      morpheus = mkSystem [ ./hosts/morpheus ];

      oracle = mkSystem [ ./hosts/oracle ];

      vm = mkSystem [ ./hosts/vm ];
    };
  };
}
