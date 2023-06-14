{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.ls.desktop;
in {
  imports = [
    ./gnome.nix
    ./hardware.nix
  ];
  options = {
    ls = {
      desktop = {
        enable = mkOption {
          type = types.bool;
          default = false;
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
      enable = true;
    };

    #environment.sessionVariables.NIXOS_OZONE_WL =
    #  if environments.${cfg.environment}.wayland
    #  then "1"
    #  else "";
  };
}
