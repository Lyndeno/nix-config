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
  ];
  options = {
    modules = {
      desktop = {
        enable = mkOption {type = types.bool; default = false; };
        supportDDC = mkOption {type = types.bool; default = false; };
        software = {
          backup = mkOption {type = types.bool; default = true; };
        };
        environment = mkOption { type = types.nullOr (types.enum ["gnome" "plasma"]); default = null; };
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
      xserver = {
        enable = true;
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
  };
}
