{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.ls.desktop;

  environments = {
    gnome = {
      wayland = true;
    };
    plasma = {
      wayland = true;
    };
    sway = {
      wayland = true;
    };
    i3 = {
      wayland = false;
    };
  };
in {
  imports = [
    ./gnome.nix
    ./plasma.nix
    ./hardware.nix
    (import ./i3-sway {inherit config lib pkgs inputs;})
  ];
  options = {
    ls = {
      desktop = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
        supportDDC = mkOption {
          type = types.bool;
          default = false;
        };
        software = {
          backup = mkOption {
            type = types.bool;
            default = true;
          };
        };
        environment = mkOption {
          type = types.nullOr (types.enum (lib.mapAttrsToList (name: _value: name) environments));
          default = null;
        };
        mainResolution = {
          width = mkOption {
            type = types.int;
            default = 1920;
          };
          height = mkOption {
            type = types.int;
            default = 1080;
          };
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
        polkitPolicyOwners = ["lsanche"];
      };
    };

    boot.kernelModules = lib.optional cfg.supportDDC "i2c_dev";
    #services.udev.extraRules = lib.optionalString cfg.supportDDC ''
    #    KERNEL=="i2c-[0-9]*", TAG+="uaccess"
    #'';

    xdg.portal = {
      enable = cfg.environment != null;
    };

    environment.sessionVariables.NIXOS_OZONE_WL =
      if environments.${cfg.environment}.wayland
      then "1"
      else "";
  };
}
