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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
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
    };

    ironfetch = {
      url = "github:Lyndeno/ironfetch/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    ppd = {
      url = "github:Lyndeno/ppd-rs/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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
      };
    };

    stylix = {
      url = "github:danth/stylix/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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

    mujmap = {
      url = "github:Lyndeno/mujmap";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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

    cmp-notmuch = {
      url = "github:michaeladler/cmp-notmuch";
      flake = false;
    };

    vpn-confinement = {
      url = "github:Maroka-chan/VPN-Confinement";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
