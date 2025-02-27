{
  description = "Lyndon's NixOS setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "nixos-hardware/master";

    multinix = {
      url = "github:lyndeno/multinix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        haumea.follows = "haumea";
        flake-parts.follows = "flake-parts";
        pre-commit-hooks-nix.follows = "pre-commit-hooks-nix";
      };
    };

    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cfetch = {
      url = "github:Lyndeno/cfetch/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    ironfetch = {
      url = "github:Lyndeno/ironfetch/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "pre-commit-hooks-nix";
        utils.follows = "flake-utils";
      };
    };

    site = {
      url = "github:Lyndeno/website-hugo";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    base16-schemes = {
      url = "github:tinted-theming/base16-schemes";
      flake = false;
    };

    wallpapers = {
      url = "github:Lyndeno/wallpapers";
      flake = false;
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        darwin.follows = "";
      };
    };

    stylix = {
      url = "github:danth/stylix/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        git-hooks.follows = "pre-commit-hooks-nix";
        flake-utils.follows = "flake-utils";
      };
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        pre-commit-hooks-nix.follows = "pre-commit-hooks-nix";
      };
    };

    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    apple-fonts = {
      # Do not follow nixpkgs as it takes forever to build each time
      # Does not matter anyway, it's just fonts
      url = "github:Lyndeno/apple-fonts.nix";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.blueprint {inherit inputs;};

  #inputs @ {
  #  flake-parts,
  #  nixpkgs,
  #  haumea,
  #  multinix,
  #  self,
  #  ...
  #}: let
  #  inherit (nixpkgs) lib;
  #  lsLib = import ./lslib.nix {inherit lib;};

  #  secretPaths = haumea.lib.load {
  #    src = ./secrets;
  #    loader = [
  #      (haumea.lib.matchers.extension "age" haumea.lib.loaders.path)
  #    ];
  #  };

  #  pubKeys = haumea.lib.load {
  #    src = ./pubKeys;
  #  };

  #  homes = multinix.lib.homes ./home;
  #in
  #  flake-parts.lib.mkFlake {inherit inputs;} {
  #    imports = [
  #      inputs.pre-commit-hooks-nix.flakeModule
  #    ];
  #    systems = [
  #      "x86_64-linux"
  #      "aarch64-linux"
  #    ];
  #    perSystem = {
  #      pkgs,
  #      config,
  #      inputs',
  #      ...
  #    }: {
  #      formatter = pkgs.alejandra;

  #      pre-commit = {
  #        check.enable = true;
  #        settings = {
  #          src = ./.;
  #          hooks = {
  #            alejandra.enable = true;
  #            statix.enable = true;
  #            deadnix.enable = true;
  #          };
  #        };
  #      };

  #      devShells.default = pkgs.mkShell {
  #        buildInputs = with pkgs; [inputs'.agenix.packages.default statix deadnix];
  #        inputsFrom = [config.pre-commit.devShell];
  #      };
  #    };
  #    flake = {
  #      nixosConfigurations = multinix.lib.makeNixosSystems {
  #        flakeRoot = ./.;
  #        specialArgs = {inherit inputs lsLib secretPaths pubKeys homes;};
  #        defaultSystem = "x86_64-linux";
  #      };

  #      hydraJobs = {
  #        inherit (self.outputs) checks devShells;
  #        nixos = builtins.mapAttrs (_name: value: value.config.system.build.toplevel) self.outputs.nixosConfigurations;
  #      };
  #    };
  #  };
}
