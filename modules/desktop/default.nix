{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.desktop;
  software = config.modules.desktop.software;
in
{
  imports = [
    ./gnome.nix
    ./plasma.nix
    ./i3-sway
  ];
  options = {
    modules = {
      desktop = {
        enable = mkOption {type = types.bool; default = false; };
        supportDDC = mkOption {type = types.bool; default = false; };
        software = {
          backup = mkOption {type = types.bool; default = true; };
        };
        environment = mkOption { type = types.nullOr (types.enum ["gnome" "plasma" "sway"]); default = null; };
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
        gid = 5000;
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
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];

    environment.systemPackages = with pkgs; [
      firefox-wayland
      alacritty
      #(lib.mkIf cfg.supportDDC ddcutil)
      brightnessctl
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
          (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
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

      programs.alacritty = {
          enable = true;
          settings = {
          font = {
              size = 11;
              normal = {
              family = "CaskaydiaCove Nerd Font Mono";
              style = "Regular";
              };
          };
          window = {
              padding = {
              x = 12;
              y = 12;
              };
              dynamic_padding = true;
              opacity = 0.95;
          };
          mouse.hide_when_typing = true;
          };
      };
    };
  };
}
