{
  description = "Lyndon's NixOS setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
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

    base16-schemes = {
      url = github:base16-project/base16-schemes;
      flake = false;
    };

    base16-vim-lightline = {
      url = github:mike-hearn/base16-vim-lightline;
      flake = false;
    };

    wallpapers = {
      url = github:Lyndeno/wallpapers;
      flake = false;
    };

    agenix = {
      url = github:ryantm/agenix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:Lyndeno/nix-style/optionalPalette";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = inputs@{ self, ... }:
  let
    makePkgs = system: import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    lib = inputs.nixpkgs.lib;

    commonModules = let
    in system: [
      inputs.home-manager.nixosModules.home-manager
      ./common
      ./modules
      ./programs
      ({config, ...}: {
        environment.systemPackages = [ inputs.cfetch.packages.${system}.default ];
      })
      inputs.stylix.nixosModules.stylix
      inputs.agenix.nixosModule
    ];

    mkSystem = name: let
      hostInfo = import ./hosts/${name}/info.nix;
    in lib.nixosSystem rec {
      system = hostInfo.system;
      pkgs = makePkgs system;
      modules = (commonModules system) ++ (import ./hosts/${name} inputs);
      specialArgs = { inherit inputs; };
    };

  in {
    nixosConfigurations = builtins.listToAttrs
    (map
      (x: {
        name = x;
        value = mkSystem x;
      })
      (builtins.attrNames (builtins.readDir ./hosts))
    );
  };
}
