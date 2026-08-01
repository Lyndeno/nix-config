# meta.description = "Shared Wayland user services: waybar, mako, swayidle, kanshi, wob"
{flake, ...}: {
  pkgs,
  osConfig,
  lib,
  ...
}: {
  imports = [
    flake.homeModules.alacritty
    ./waybar.nix
    ./services.nix
  ];
  xdg.mimeApps = let
    imageTypes = [
      "image/jpeg"
      "image/png"
      "image/gif"
      "image/webp"
      "image/tiff"
      "image/bmp"
      "image/svg+xml"
      "image/svg+xml-compressed"
      "image/avif"
      "image/heic"
      "image/jxl"
      "image/x-tga"
      "image/vnd-ms.dds"
      "image/x-dds"
      "image/vnd.microsoft.icon"
      "image/vnd.radiance"
      "image/x-exr"
      "image/x-portable-bitmap"
      "image/x-portable-graymap"
      "image/x-portable-pixmap"
      "image/x-portable-anymap"
      "image/x-qoi"
    ];
    browserTypes = [
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/chrome"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
      "text/html"
      "application/xhtml+xml"
      "application/x-extension-htm"
      "application/x-extension-html"
      "application/x-extension-shtml"
      "application/x-extension-xhtml"
      "application/x-extension-xht"
    ];
  in {
    enable = true;
    defaultApplications =
      lib.genAttrs imageTypes (_: "imv.desktop")
      // lib.genAttrs browserTypes (_: "org.qutebrowser.qutebrowser.desktop")
      // {
        "application/pdf" = "org.pwmt.zathura.desktop";
      };
  };

  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:";
    };
  };

  home.packages = with pkgs; [
    wireplumber
    brightnessctl
    nautilus
    xdg-user-dirs-gtk
    gnome-clocks
    #fractal
    bzmenu
    iwmenu
    pwmenu
    playerctl
    webcam-picker
    lock-screen
  ];

  programs = {
    fuzzel.enable = true;
    imv.enable = true;
    swaylock = {
      enable = true;
      settings.image = pkgs.wallpaper.blurred.darken;
    };
    zathura = {
      enable = true;
      options.selection-clipboard = "clipboard";
    };
    mpv = let
      inherit (osConfig.networking) hostName;
    in {
      enable = true;
      config = {
        osc = "no";
        cache = "yes";
        cache-secs = 600;
        hwdec = "vaapi,auto-safe";
        vo = "dmabuf-wayland";
        watch-later-options-remove = "sub-pos";
        ytdl-format =
          if hostName == "neo"
          then "bestvideo[height>=?1440][vcodec^=vp9]+bestaudio/bestvideo+bestaudio/best"
          else "bestvideo[height>=?1440][vcodec^=av01]+bestaudio/bestvideo[height<=?1440][vcodec^=vp9]+bestaudio/bestvideo+bestaudio/best";
      };
      scripts = with pkgs.mpvScripts; [
        mpris
        modernz
        thumbfast
      ];
      scriptOpts = {
        thumbfast = {
          network = "yes";
          hwdec = "yes";
        };
      };
    };
  };
}
