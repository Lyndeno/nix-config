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

    site = {
      url = github:Lyndeno/website-hugo;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, home-manager, nixos-hardware, cfetch, site, ... }:
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

      oracle = mkSystem [
        ./hosts/oracle
        ({config, ...}: {
          networking.firewall.allowedTCPPorts = [
            80
            443
          ];
          services.nginx.enable = true;
          services.nginx.virtualHosts."cloud.lyndeno.ca" = {
            root = "${site.packages.${system}.default}/";
          };
        })
      ];

      vm = mkSystem [ ./hosts/vm ];
    };
  };
}
