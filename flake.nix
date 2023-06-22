{
  description = "Lyndon's NixOS setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "nixos-hardware/master";
    deploy-rs.url = "github:serokell/deploy-rs";
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

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
    haumea,
    ...
  }: let
    inherit (nixpkgs) lib;
    lsLib = import ./lslib.nix {inherit lib;};

    # deadnix: skip
    loadCfg = folder: ({pkgs, ...} @ args:
      haumea.lib.load {
        src = folder;
        inputs = args;
        transformer = haumea.lib.transformers.liftDefault;
      });

    common = loadCfg ./common;

    mkSystem = folder: name: let
      system = import ./${folder}/${name}/_localSystem.nix;

      hostCfg = loadCfg ./${folder}/${name};
    in
      lib.nixosSystem {
        inherit system;
        modules = [
          hostCfg
          common
          {networking.hostName = name;}
        ];
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
        system,
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

        checks = (builtins.mapAttrs (_system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib).${system};

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

        deploy.nodes.oracle = {
          hostname = "oracle";
          profiles.system = {
            user = "root";
            remoteBuild = true;
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.oracle;
          };
        };

        deploy.nodes.trinity = {
          hostname = "trinity";
          profiles.system = {
            user = "root";
            remoteBuild = true;
            path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.trinity;
          };
        };
      };
    };
}
