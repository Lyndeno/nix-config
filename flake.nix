{
  description = "Lyndon's NixOS setup";

  outputs = inputs @ {
    self,
    flake-parts,
    multinix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.git-hooks.flakeModule
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

        #checks.niri-config = pkgs.stdenvNoCC.mkDerivation {
        #  name = "niri-validate";
        #  src = ./.;
        #  doCheck = true;
        #  nativeBuildInputs = [pkgs.niri];
        #  buildPhase = ''
        #    touch $out
        #  '';
        #  checkPhase = ''
        #    niri validate -c ./home/lsanche/home/config.kdl
        #  '';
        #};
      };
      flake =
        (multinix.lib.multinix inputs)
        // {
          githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {inherit (self) checks;};
        };
    };

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-25.11-small/nixexprs.tar.xz";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "nixos-hardware/master";

    multinix = {
      url = "github:lyndeno/multinix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "";
    };

    ironfetch = {
      url = "github:Lyndeno/ironfetch/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "";
        nix-github-actions.follows = "";
      };
    };

    ppd = {
      url = "github:Lyndeno/ppd-rs/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "";
        nix-github-actions.follows = "";
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
      url = "github:danth/stylix/release-25.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        nur.follows = "";
      };
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "";
        flake-compat.follows = "";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mujmap = {
      url = "github:Lyndeno/mujmap";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "";
        nix-github-actions.follows = "";
      };
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        nuschtosSearch.follows = "";
      };
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cmp-notmuch = {
      url = "github:michaeladler/cmp-notmuch";
      flake = false;
    };

    nixarr = {
      url = "github:rasmus-kirk/nixarr";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        website-builder.follows = "";
      };
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
