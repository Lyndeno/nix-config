{
  pkgs,
  flake,
  ...
}: {
  imports = with flake.homeModules; [
    spotify
  ];

  manual.html.enable = true;

  programs.firefox = {
    enable = true;
    profiles.lsanche = {
      id = 0;
      isDefault = true;
      settings = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
  };

  stylix = {
    targets = {
      swaylock = {
        useWallpaper = false;
        enable = true;
      };
      firefox.profileNames = ["lsanche"];
      vscode.profileNames = ["default"];
      waybar = {
        font = "sansSerif";
      };

      # this has ifd
      blender.enable = false;
    };
  };

  home = {
    sessionVariables = {
      BROWSER = "firefox";
      SSH_AUTH_SOCK = "\${SSH_AUTH_SOCK:-$HOME/.1password/agent.sock}";
      GSM_SKIP_SSH_AGENT_WORKAROUND = "1";
    };

    packages = with pkgs; [
      # Communication
      slack

      #wally-cli # for moonlander
      wl-clipboard

      # media
      #inkscape
      gimp
      #darktable

      # Office
      #kicad
      #octaveFull
      joplin-desktop

      hunspellDicts.en_CA

      libreoffice

      logseq
    ];
  };
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
    };
    configFile."autostart/gnome-keyring-ssh.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=SSH Key Agent
        Comment=GNOME Keyring: SSH Agent
        Exec=/run/wrappers/bin/gnome-keyring-daemon --start --components=ssh
        OnlyShowIn=GNOME;Unity;MATE;
        X-GNOME-Autostart-Phase=PreDisplayServer
        X-GNOME-AutoRestart=false
        X-GNOME-Autostart-Notify=true
        Hidden=true
      '';
    };
  };
}
