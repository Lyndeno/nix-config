# meta.description = "Desktop user apps (Firefox, Spotify, qutebrowser)"
{flake, ...}: {pkgs, ...}: {
  imports = with flake.homeModules; [
    spotify
    qutebrowser
  ];

  manual.html.enable = true;

  programs.chromium = {
    enable = true;
    # Dark pages by default, like qutebrowser's colors.webpage.darkmode:
    # commandLineArgs = ["--enable-features=WebContentsForceDark"];
    extensions = [
      # Open in mpv (needs the open-in-mpv binary and mpv:// handler below)
      {
        id = "ggijpepdpiehgbiknmfpfbhcalffjlbj";
      }
      # 1Password
      {
        id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";
      }
      # UBlock Origin Lite
      {
        id = "ddkjiahejlhfcafbddmgiahcphecmpfh";
      }
    ];
  };

  #programs.firefox = {
  #  enable = true;
  #  configPath = ".mozilla/firefox";
  #  profiles.lsanche = {
  #    id = 0;
  #    isDefault = true;
  #    extensions.force = true;
  #    settings = {
  #      "widget.use-xdg-desktop-portal.file-picker" = 1;
  #    };
  #  };
  #};

  #programs.librewolf = {
  #  enable = true;
  #  profiles.lsanche = {
  #    id = 0;
  #    isDefault = true;
  #    extensions.force = true;
  #    settings = {
  #      "widget.use-xdg-desktop-portal.file-picker" = 1;
  #    };
  #  };
  #};

  stylix = {
    targets = {
      swaylock = {
        useWallpaper = false;
        enable = true;
      };
      firefox = {
        profileNames = ["lsanche"];
        colorTheme.enable = true;
      };
      librewolf = {
        profileNames = ["lsanche"];
        colorTheme.enable = true;
      };
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
      BROWSER = "qutebrowser";
      SSH_AUTH_SOCK = "\${SSH_AUTH_SOCK:-$HOME/.1password/agent.sock}";
      GSM_SKIP_SSH_AGENT_WORKAROUND = "1";
    };

    packages = with pkgs; [
      # Communication
      slack
      fractal

      #wally-cli # for moonlander
      wl-clipboard

      # media
      #inkscape
      gimp
      #darktable

      # Office
      #kicad
      #octaveFull
      #joplin-desktop

      hunspellDicts.en_CA

      libreoffice

      # logseq depends on electron-39 which is EOL and marked insecure in nixpkgs
      #logseq

      claude-desktop

      open-in-mpv
    ];
  };
  xdg = {
    enable = true;
    # open-in-mpv's extension hands links to the mpv:// scheme handler
    mimeApps.defaultApplications."x-scheme-handler/mpv" = "open-in-mpv.desktop";
    userDirs = {
      enable = true;
      setSessionVariables = false;
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
