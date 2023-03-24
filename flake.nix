{
  description = "Lyndon's NixOS setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "nixos-hardware/master";

    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
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
  };

  outputs = inputs @ {self, ...}: let
    lsLib = import ./lslib.nix;
    makePkgs = system:
      import inputs.nixpkgs rec {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    inherit (inputs.nixpkgs) lib;

    commonModules = system: [
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
        inherit (hostInfo) system;
        pkgs = makePkgs system;
        modules = import ./${folder}/${name} lib inputs (commonModules system);
        specialArgs = {inherit inputs lsLib;};
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
        (lsLib.ls ./${folder})
      )) "hosts";

    formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;

    checks.x86_64-linux = let
      pkgs = makePkgs "x86_64-linux";
    in {
      pre-commit-check = inputs.pre-commit-hooks-nix.lib."x86_64-linux".run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          statix.enable = true;
          #deadnix.enable = true;
        };
      };
    };

    devShells.x86_64-linux.default = let
      pkgs = makePkgs "x86_64-linux";
    in
      pkgs.mkShell {
        buildInputs = with pkgs; [inputs.agenix.packages.x86_64-linux.default statix deadnix];
        inherit (self.checks.x86_64-linux.pre-commit-check) shellHook;
      };
  };
}
