{
  description = "Lyndon's NixOS setup";

  outputs = inputs:
    (inputs.blueprint {
      inherit inputs;
      systems = ["x86_64-linux" "aarch64-linux"];
    })
    // {
      githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {inherit (inputs.self) checks;};
    };

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "nixos-hardware/master";

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
      url = "github:danth/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nur.follows = "";
      };
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit.follows = "";
      };
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
        pre-commit-hooks-nix.follows = "";
        nix-github-actions.follows = "";
      };
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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

    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "";
    };

    rpi4-uefi = {
      url = "https://github.com/pftf/RPi4/releases/download/v1.50/RPi4_UEFI_Firmware_v1.50.zip";
      flake = false;
    };
  };
}
