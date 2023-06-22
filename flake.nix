{
  description = "Lyndon's NixOS setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "nixos-hardware/master";

    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cfetch = {
      url = "github:Lyndeno/cfetch/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ironfetch = {
      url = "github:Lyndeno/ironfetch/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    site = {
      url = "github:Lyndeno/website-hugo";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base16-schemes = {
      url = "github:tinted-theming/base16-schemes";
      flake = false;
    };

    base16-vim-lightline = {
      url = "github:mike-hearn/base16-vim-lightline";
      flake = false;
    };

    wallpapers = {
      url = "github:Lyndeno/wallpapers";
      flake = false;
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    statix = {
      url = "github:nerdypepper/statix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}: let
    inherit (inputs.nixpkgs) lib;
    lsLib = import ./lslib.nix {inherit lib;};

    # deadnix: skip
    common = {pkgs, ...} @ args:
      inputs.haumea.lib.load {
        src = ./common;
        inputs = args;
        transformer = inputs.haumea.lib.transformers.liftDefault;
      };

    commonModules = [
      inputs.home-manager.nixosModules.home-manager
      ./mods
      common
      {
        nixpkgs.config.allowUnfree = true;
      }
      inputs.stylix.nixosModules.stylix
      inputs.agenix.nixosModules.default
    ];

    mkSystem = folder: name: let
      system = import ./${folder}/${name}/_localSystem.nix;
      # deadnix: skip
      hostCfg = {pkgs, ...} @ args:
        inputs.haumea.lib.load {
          src = ./${folder}/${name};
          inputs = args;
          transformer = [
            inputs.haumea.lib.transformers.liftDefault
          ];
        };
    in
      lib.nixosSystem {
        inherit system;
        modules =
          [
            hostCfg
            {networking.hostName = name;}
          ]
          ++ commonModules;
        specialArgs = {
          inherit inputs lsLib;
        };
      };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.pre-commit-hooks-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem = {
        pkgs,
        lib,
        config,
        inputs',
        ...
      }: let
        statix' = inputs'.statix.packages.statix;
      in {
        formatter = pkgs.alejandra;

        pre-commit = {
          check.enable = true;
          settings = {
            src = ./.;
            hooks = {
              alejandra.enable = true;
              statix.enable = true;
              deadnix.enable = true;
            };
            tools = {
              # Current version (0.5.6) incorrectly reports syntax errors in ./common/users.nix
              statix = lib.mkForce statix';
            };
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [inputs'.agenix.packages.default statix' pkgs.deadnix];
          inputsFrom = [config.pre-commit.devShell];
        };
      };
      flake = {
        nixosConfigurations = (folder:
          builtins.listToAttrs
          (
            map
            (x: {
              name = x;
              value = mkSystem folder x;
            })
            (lsLib.ls ./${folder})
          )) "hosts";
      };
    };
}
