{
  description = "Lyndon's NixOS setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  
  outputs = { self, nixpkgs, home-manager, ... }:
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
        ];
      };
    };
  };
}
