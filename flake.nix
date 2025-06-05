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

    ironfetch = {
      url = "github:Lyndeno/ironfetch/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "pre-commit-hooks-nix";
        utils.follows = "flake-utils";
      };
    };

    ppd = {
      url = "github:Lyndeno/ppd-rs/master";
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
      url = "github:tinted-theming/schemes";
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
        flake-parts.follows = "flake-parts";
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

    mujmap = {
      url = "github:Lyndeno/mujmap";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "pre-commit-hooks-nix";
        utils.follows = "flake-utils";
      };
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    multinix,
    ...
  }:
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
        config,
        inputs',
        ...
      }: {
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
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [inputs'.agenix.packages.default statix deadnix];
          inputsFrom = [config.pre-commit.devShell];
        };

        checks.niri-config = pkgs.stdenvNoCC.mkDerivation {
          name = "niri-validate";
          src = ./.;
          doCheck = true;
          nativeBuildInputs = [pkgs.niri];
          buildPhase = ''
            touch $out
          '';
          checkPhase = ''
            niri validate -c ./home/lsanche/home/config.kdl
          '';
        };
      };
      flake =
        (multinix.lib.multinix inputs)
        // {
          githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {inherit (self) checks;};
        };
    };
}
