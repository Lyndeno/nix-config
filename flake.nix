{
  description = "Lyndon's NixOS setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "nixos-hardware/master";
    cfetch = {
      url = github:Lyndeno/cfetch/master;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    site = {
      url = github:Lyndeno/website-hugo;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base16-schemes = {
      url = github:base16-project/base16-schemes;
      flake = false;
    };

    base16-vim-lightline = {
      url = github:mike-hearn/base16-vim-lightline;
      flake = false;
    };

    base16-waybar = {
      url = github:mnussbaum/base16-waybar;
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
      url = github:danth/stylix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = inputs@{ self, ... }:
  let
    pkgs = system: import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    lib = inputs.nixpkgs.lib;

    commonModules = let
      base16Scheme = "${inputs.base16-schemes}/gruvbox-dark-hard.yaml";
    in system: [
      inputs.home-manager.nixosModules.home-manager
      ./common
      ./users
      ./modules
      ./programs
      ({config, ...}: {
        environment.systemPackages = [ inputs.cfetch.packages.${system}.default ];
      })
      inputs.stylix.nixosModules.stylix
      ({config, pkgs, ...}: {
        #nixpkgs.overlays = [ (self: super: {
        #  myTheme = self.writeText "myTheme.yaml" builtins.readFile base16Scheme;
        #}) ];
        stylix.image = "${inputs.wallpapers}/starry.jpg";
        #lib.stylix.colors = config.lib.base16.mkSchemeAttrs base16Scheme;
        stylix.base16Scheme = let
          myTheme = pkgs.writeTextFile { name = "myTheme.yaml"; text = builtins.replaceStrings [ "Gruvbox dark, hard" ] [ "Gruvbox" ] (builtins.readFile base16Scheme); destination = "/myTheme.yaml"; };
        in "${myTheme}/myTheme.yaml";
        stylix.fonts = let
          cascadia = (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" ]; });
        in {
          serif = {
            package = cascadia;
            name = "CaskaydiaCove Nerd Font";
          };
          sansSerif = {
            package = cascadia;
            name = "CaskaydiaCove Nerd Font";
          };
          monospace = {
            package = cascadia;
            name = "CaskaydiaCove Nerd Font Mono";
          };
        };

      })
      inputs.agenix.nixosModule
    ];

    mkSystem = system: extraModules: lib.nixosSystem {
      pkgs = pkgs system;
      inherit system;
      modules = (commonModules system) ++ extraModules;
      specialArgs = { inherit inputs; };
    };

  in {
    nixosConfigurations = {
      neo = with inputs.nixos-hardware.nixosModules; mkSystem "x86_64-linux" [
        ./hosts/neo
        dell-xps-15-9560-intel
        common-cpu-intel-kaby-lake
        ({config, ...}: {
          specialisation.nvidia = {
            inheritParentConfig = false;
            configuration = {
              imports = [
                ./hosts/neo
                inputs.nixos-hardware.nixosModules.dell-xps-15-9560-nvidia
                common-cpu-intel-kaby-lake
              ] ++ commonModules "x86_64-linux";

              modules.desktop.environment = lib.mkForce "i3";
              hardware.nvidia = {
                prime = {
                  offload.enable = false;
                  sync.enable = true;
                };
                modesetting.enable = true;
              };
            };
          };
        })
      ];

      morpheus = mkSystem "x86_64-linux" [ ./hosts/morpheus ];

      oracle = let
        system = "x86_64-linux";
      in mkSystem system [
        ./hosts/oracle
        ({config, ...}: {
          networking.firewall.allowedTCPPorts = [
            80
            443
          ];
          services.nginx.enable = true;
          services.nginx.virtualHosts."cloud.lyndeno.ca" = {
            root = "${inputs.site.packages.${system}.default}/";
          };
        })
      ];

      trinity = mkSystem "aarch64-linux" [ ./hosts/trinity ];
    };
  };
}
