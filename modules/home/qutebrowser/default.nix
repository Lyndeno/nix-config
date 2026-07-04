{
  lib,
  config,
  pkgs,
  ...
}: {
  programs.qutebrowser = {
    enable = true;
    settings = {
      window.hide_decoration = true;
      statusbar.show = "in-mode";
      scrolling.bar = "never";
      tabs = {
        show = "switching";
        position = "left";
        last_close = "close";
      };
      colors.webpage.darkmode.enabled = true;
      editor.command = ["alacritty" "--class" "hover" "-e" "nvim" "+startinsert" "{}"];
      session.lazy_restore = true;
      content.dns_prefetch = true;
      auto_save = {
        session = true;
        interval = 15000;
      };
      fileselect = {
        handler = "external";
        single_file.command = ["${lib.getExe pkgs.zenity}" "--file-selection"];
        multiple_files.command = ["${lib.getExe pkgs.zenity}" "--file-selection" "--multiple"];
        folder.command = ["${lib.getExe pkgs.zenity}" "--file-selection" "--directory"];
      };
      content.blocking = {
        enabled = true;
        method = "both";
      };
      # Temporary fix for video not working
      qt.args = [
        "disable-features=AcceleratedVideoDecodeLinuxGL"
        "enable-features=AcceleratedVideoEncoder"
      ];
    };
    searchEngines = rec {
      ddg = "https://duckduckgo.com/?q={}";
      g = "https://google.com/search?hl=en&q={}";
      gh = "https://github.com/search?q={}";
      np = "https://search.nixos.org/packages?channel=unstable&query={}";
      no = "https://search.nixos.org/options?channel=unstable&query={}";
      nd = "https://discourse.nixos.org/search?q={}";
      ng = "https://noogle.dev/q/?term={}";
      yt = "https://www.youtube.com/results?search_query={}";
      DEFAULT = ddg;
    };
    perDomainSettings =
      lib.genAttrs [
        "outlook.cloud.microsoft"
        "teams.microsoft.com"
        "gitlab.com"
        "discourse.nixos.org"
      ] (_: {
        content.notifications.enabled = true;
      });
    keyBindings = {
      normal = {
        "<Ctrl-e>" = lib.mkMerge [
          "config-cycle tabs.show switching always"
          "config-cycle statusbar.show in-mode always"
          "config-cycle scrolling.bar never overlay"
        ];
        "<Ctrl-d>" = "config-cycle colors.webpage.darkmode.enabled true false";
        "<Ctrl-,>" = lib.mkMerge [
          "hint links spawn --detach ${lib.getExe config.programs.mpv.finalPackage} {hint-url}"
          "message-info 'Opening hinted link in MPV...'"
        ];
        "<Ctrl-m>" = lib.mkMerge [
          "spawn --detach ${lib.getExe config.programs.mpv.finalPackage} {url}"
          "jseval -q document.querySelectorAll('video,audio').forEach(m => m.pause())"
          "message-info 'Opening current URL in MPV and pausing page media...'"
        ];
      };
    };
  };
}
