{
  description = "Lyndon's NixOS setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "nixos-hardware/master";
    utils.url = "github:numtide/flake-utils";
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

    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };

    statix = {
      url = "github:nerdypepper/statix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    utils,
    ...
  }: let
    makePkgs = system:
      import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    inherit (inputs.nixpkgs) lib;
    lsLib = import ./lslib.nix {inherit lib;};

    commonModules = system: [
      inputs.home-manager.nixosModules.home-manager
      ./common.nix
      ./modules
      ./desktop
      ./users
      {
        environment.systemPackages = [
          inputs.cfetch.packages.${system}.default
          inputs.ironfetch.packages.${system}.default
        ];
      }
      inputs.stylix.nixosModules.stylix
      inputs.agenix.nixosModules.default
    ];

    mkSystem = folder: name: let
      hostInfo = import ./${folder}/${name}/info.nix;
    in
      lib.nixosSystem rec {
        inherit (hostInfo) system;
        pkgs = makePkgs system;
        modules =
          (import ./${folder}/${name} lib inputs (commonModules system))
          ++ [
            {networking.hostName = name;}
          ];
        specialArgs = {
          inherit inputs lsLib;
          hostName = name;
        };
      };
  in
    {
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
    }
    // (utils.lib.eachDefaultSystem (system: let
        pkgs = makePkgs system;
        inherit (inputs.statix.packages.${system}) statix;
      in {
        formatter = pkgs.alejandra;

        checks =
          {
            pre-commit-check = inputs.pre-commit-hooks-nix.lib.${system}.run {
              src = ./.;
              hooks = {
                alejandra.enable = true;
                statix.enable = true;
                deadnix.enable = true;
              };

              tools = {
                # Current version (0.5.6) incorrectly reports syntax errors in ./common/users.nix
                inherit statix;
              };
            };
          }
          // (builtins.mapAttrs (_: deploylib: deploylib.deployChecks self.deploy) inputs.deploy-rs.lib).${system};

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [inputs.agenix.packages.${system}.default statix deadnix inputs.deploy-rs.packages.${system}.default];
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
      })
      // {
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

        #checks = builtins.mapAttrs (system: deploylib: deploylib.deployChecks self.deploy) inputs.deploy-rs.lib;
      });
}
