{config, lib, pkgs, inputs, ...}:

with lib;

let
  cfg = config.modules.desktop;
  software = config.modules.desktop.software;
  defaults = {
    font = {
      package = (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" ]; });
      name = "CaskaydiaCove Nerd Font";
    };
  };
in
{
  imports = [
    ./gnome.nix
    ./plasma.nix
    ./hardware.nix
    (import ./i3-sway { inherit config lib pkgs defaults inputs; })
    ../../programs/desktop
  ];
  options = {
    modules = {
      desktop = {
        enable = mkOption {type = types.bool; default = false; };
        supportDDC = mkOption {type = types.bool; default = false; };
        software = {
          backup = mkOption {type = types.bool; default = true; };
        };
        environment = mkOption { type = types.nullOr (types.enum ["gnome" "plasma" "sway" "i3"]); default = null; };
        mainResolution = {
          width = mkOption { type = types.int; default = 1920; };
          height = mkOption { type = types.int; default = 1080; };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    hardware.pulseaudio.enable = false; # use pipewire instead
    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };

    security = {
      rtkit.enable = true; # Realtime pipewire
      pam.services = {
        login.u2fAuth = false;
      };
    };

    programs = {
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "lsanche" ];
      };
    };

    boot.kernelModules = lib.optional cfg.supportDDC "i2c_dev";
    #services.udev.extraRules = lib.optionalString cfg.supportDDC ''
    #    KERNEL=="i2c-[0-9]*", TAG+="uaccess"
    #'';

    xdg.portal = {
      enable = (cfg.environment != null);
    };

    fonts.fonts = with pkgs; [
      defaults.font.package
    ];

    environment.systemPackages = with pkgs; [
      firefox-wayland
      google-chrome
      alacritty
      #(lib.mkIf cfg.supportDDC ddcutil)
      ( symlinkJoin {
        name = "vscode";
        pname = "vscode";
        paths = [ pkgs.vscode ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/code \
            --add-flags "--ozone-platform=wayland --enable-features=WaylandWindowDecorations"
        '';
      })
    ];

    home-manager.users.lsanche = {
      home.packages = with pkgs; [
          defaults.font.package
          spotify
          zathura
          signal-desktop
          spotify
          discord
          libreoffice-qt
          imv
          #avizo
          #pamixer
      ];

      gtk = {
          enable = true;
          theme.name = "Adwaita-dark";
          theme.package = pkgs.gnome.gnome-themes-extra;
          iconTheme.name = "Papirus-Dark";
          iconTheme.package = pkgs.papirus-icon-theme;
      };

      programs.ssh.matchBlocks = {
        "* !*.repo.borgbase.com" = {
          extraOptions = {
            "IdentityAgent" = "~/.1password/agent.sock"; # 1password **should** exist if desktop is enabled
          };
        };
      };
    };
  };
}
