{
  description = "Lyndon's NixOS setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "nixos-hardware/master";

    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
    };

    cfetch = {
      url = github:Lyndeno/cfetch/master;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ironfetch = {
      url = github:Lyndeno/ironfetch/master;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    site = {
      url = github:Lyndeno/website-hugo;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base16-schemes = {
      url = github:tinted-theming/base16-schemes;
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
  };

  outputs = inputs @ {self, ...}: let
    makePkgs = system:
      import inputs.nixpkgs rec {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          (final: prev: {
            unstable = import inputs.nixpkgs-unstable {inherit system config;};
            plex = final.unstable.plex;
            _1password-gui = final.unstable._1password-gui;
            rust-analyzer = final.unstable.rust-analyzer;
            # The version of rust-analyzer in 22.11 has a bug that causes it to just not work sometimes
            vscode-extensions =
              prev.vscode-extensions
              // {
                matklad =
                  prev.vscode-extensions.matklad
                  // {
                    rust-analyzer = final.unstable.vscode-extensions.matklad.rust-analyzer;
                  };
              };
          })
        ];
      };
    lib = inputs.nixpkgs.lib;

    commonModules = let
    in
      system: [
        inputs.home-manager.nixosModules.home-manager
        ./common
        ./modules
        ./programs
        ./desktop
        ({config, ...}: {
          environment.systemPackages = [
            inputs.cfetch.packages.${system}.default
            inputs.ironfetch.packages.${system}.default
          ];
        })
        inputs.stylix.nixosModules.stylix
        inputs.agenix.nixosModules.default
      ];

    mkSystem = folder: name: let
      hostInfo = import ./${folder}/${name}/info.nix;
    in
      lib.nixosSystem rec {
        system = hostInfo.system;
        pkgs = makePkgs system;
        modules = import ./${folder}/${name} lib inputs (commonModules system);
        specialArgs = {inherit inputs;};
      };
  in {
    nixosConfigurations = (folder:
      builtins.listToAttrs
      (
        map
        (x: {
          name = x;
          value = mkSystem folder x;
        })
        (builtins.attrNames (builtins.readDir ./${folder}))
      )) "hosts";

    formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;

    devShells.x86_64-linux.default = let
      pkgs = makePkgs "x86_64-linux";
      pre-commit-format = inputs.pre-commit-hooks-nix.lib."x86_64-linux".run {
        src = ./.;

        hooks = {
          alejandra.enable = true;
        };
      };
    in
      pkgs.mkShell {
        buildInputs = [inputs.agenix.packages.x86_64-linux.default];
        shellHook = ''
          ${pre-commit-format.shellHook}
        '';
      };
  };
}
