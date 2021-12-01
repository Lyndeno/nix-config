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
          };
      };
  };

  config = mkIf cfg.enable {
	services.xserver.enable = true;
	services.xserver.displayManager.gdm = {
		enable = true;
		wayland = true;
	};

    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    };

    programs.sway = {
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
        ];
        extraSessionCommands = ''
            eval $(gnome-keyring-daemon --start --daemonize)
            export SSH_AUTH_SOCK
			source ~/.profile || true
            export GIO_EXTRA_MODULES="$GIO_EXTRA_MODULES:${pkgs.gnome.gvfs}/lib/gio/modules"
        '';
            #export > /tmp/sway.txt
    };

    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };

    fonts.fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];

	# verify this is where this should be
	services.gnome.gnome-keyring.enable = true;

    services.gvfs.enable = true; # for nautilus
    programs.seahorse.enable = true;

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
        #gnome.seahorse
		libnotify
        glib
        capitaine-cursors
    ];
  };
}
