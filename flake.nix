{
  description = "Lyndon's NixOS setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
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

    base16 = {
      url = github:SenchoPens/base16.nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base16-alacritty = {
      url = github:aarowill/base16-alacritty;
      flake = false;
    };

    base16-schemes = {
      url = github:base16-project/base16-schemes;
      flake = false;
    };

    base16-sway = {
      url = github:rkubosz/base16-sway;
      flake = false;
    };
    base16-vim = {
      url = github:base16-project/base16-vim;
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
      url = github:Lyndeno/nix-style/develop;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = inputs@{ self, ... }:
  let
    system = "x86_64-linux";

    pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    lib = inputs.nixpkgs.lib;

    commonModules = let
      base16Scheme = "${inputs.base16-schemes}/gruvbox-dark-hard.yaml";
    in [
      inputs.home-manager.nixosModules.home-manager
      ./common.nix
      ./users
      ./modules
      ./programs
      ({config, ...}: {
        environment.systemPackages = [ inputs.cfetch.packages.${system}.default ];
      })
      inputs.base16.nixosModule {
        scheme = base16Scheme;
      }
      inputs.stylix.nixosModules.stylix
      ({config, pkgs, ...}: {
        stylix.image = "${inputs.wallpapers}/lake_louise.jpg";
        lib.stylix.colors = config.lib.base16.mkSchemeAttrs base16Scheme;
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

    mkSystem = extraModules: lib.nixosSystem {
      inherit system pkgs;
      modules = commonModules ++ extraModules;
      specialArgs = { inherit inputs; };
    };

  in {
    nixosConfigurations = {
      neo = with inputs.nixos-hardware.nixosModules; mkSystem [
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
              ] ++ commonModules;

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

      morpheus = mkSystem [ ./hosts/morpheus ];

      oracle = mkSystem [
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

      vm = mkSystem [ ./hosts/vm ];
    };
  };
}
