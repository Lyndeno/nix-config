{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.desktop;
in
{
  options = {
      modules = {
          desktop = {
              enable = mkOption {type = types.bool; default = false; };
              supportDDC = mkOption {type = types.bool; default = false; };
          };
      };
  };

  config = mkIf cfg.enable {

    services = {
        pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
        };
        #gnome.gnome-keyring.enable = true;
        #gvfs.enable = true; # for nautilus
    };
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;


    security = {
        rtkit.enable = true; # Realtime pipewire
    };

    programs = {
    };
  programs._1password-gui = {
	enable = true;
	polkitPolicyOwners = [ "lsanche" ];
	gid = 5000;
};


    boot.kernelModules = lib.optional cfg.supportDDC "i2c_dev";
    services.udev.extraRules = lib.optionalString cfg.supportDDC ''
        KERNEL=="i2c-[0-9]*", TAG+="uaccess"
    '';

    xdg.portal = {
        enable = true;
    };

    fonts.fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];

    hardware.pulseaudio.enable = false; # use pipewire instead

    environment.systemPackages = with pkgs; with plasma5Packages; [
        firefox-wayland
        pavucontrol
        kmail
        kalendar
        kaddressbook
        kontact
        kmail-account-wizard
        kmailtransport
        accounts-qt
        kdiskmark
        #(symlinkJoin {
        #    name = "vscode";
        #    paths = [ vscode ];
        #    buildInputs = [ makeWrapper ];
        #    postBuild = ''
        #        wrapProgram $out/bin/code \
        #        --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
        #    '';
        #})
        alacritty
        gnome.nautilus
        libnotify
        capitaine-cursors
        (lib.mkIf cfg.supportDDC ddcutil)
        brightnessctl
        pulseaudio # for pactl
        xdg-utils
    ];
  };
}
