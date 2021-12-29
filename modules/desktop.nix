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
        xserver = {
            enable = true;
            #displayManager.sddm.enable = true;
            #libinput.enable = true;
            displayManager.gdm.enable = true;
        };
        pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
        };
        gnome.gnome-keyring.enable = true;
        gvfs.enable = true; # for nautilus
    };

    security = {
        rtkit.enable = true; # Realtime pipewire
        #pam.services.sddm.enableGnomeKeyring = true;
    };

    programs = {
        sway = {
            enable = true;
            wrapperFeatures.gtk = true;
            extraPackages = with pkgs; [
                swaylock
                swayidle
                wl-clipboard
                mako
                alacritty
                wofi
                waybar
                gammastep
                playerctl
                slurp
                grim
                acpi # for sway-idle to detect if plugged in
            ];
            extraOptions = [
                "--my-next-gpu-wont-be-nvidia"
            ];
            extraSessionCommands = ''
                eval $(gnome-keyring-daemon --start --daemonize)
                export SSH_AUTH_SOCK
                source ~/.profile || true
            '';
                #export GIO_EXTRA_MODULES="$GIO_EXTRA_MODULES:${pkgs.gnome.gvfs}/lib/gio/modules"
                #export > /tmp/sway.txt
        };
        gnupg.agent.pinentryFlavor = "gnome3";
        seahorse.enable = true;
    };

    # a fix until nautilus .desktop env vars are fixed
    environment.sessionVariables.GIO_EXTRA_MODULES = "${pkgs.gnome.gvfs}/lib/gio/modules";
    #:${pkgs.glib-networking.out}/lib/gio/modules
    #:${pkgs.dconf.lib}/lib/gio/modules

    environment.variables.GIO_EXTRA_MODULES = mkForce config.environment.sessionVariables.GIO_EXTRA_MODULES;

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

    environment.systemPackages = with pkgs; [
        firefox-wayland
        spotify
        zathura
        pavucontrol
        signal-desktop
        (symlinkJoin {
            name = "vscode";
            paths = [ vscode ];
            buildInputs = [ makeWrapper ];
            postBuild = ''
                wrapProgram $out/bin/code \
                --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
            '';
        })
        alacritty
        papirus-icon-theme
        gnome.nautilus
		libnotify
        capitaine-cursors
        discord
        (lib.mkIf cfg.supportDDC ddcutil)
        brightnessctl
        pulseaudio # for pactl
        xdg-utils
    ];
  };
}
