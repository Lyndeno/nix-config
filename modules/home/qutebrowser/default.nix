# meta.description = "qutebrowser keyboard-driven web browser"
{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.lib.stylix) colors;
  inherit (config.stylix) opacity;

  # qutebrowser's colours take rgba() with the alpha as a 0-255 value or a
  # percentage, so stylix's 0-1 opacities become percentages here.
  translucent = alpha: color: let
    channel = c: colors."${color}-rgb-${c}";
  in "rgba(${channel "r"}, ${channel "g"}, ${channel "b"}, ${toString (builtins.floor (alpha * 100 + 0.5))}%)";
in {
  programs.qutebrowser = {
    enable = true;
    settings = {
      # Let the tab bar show the desktop through, the way the GTK sidebars do
      # (see modules/home/wlroots/gtk.nix); niri blurs what comes through it.
      # The web view paints its own background, so only the bar goes see-through.
      # Stylix owns these colours, hence the overrides.
      window.transparent = true;
      window.hide_decoration = true;
      statusbar.show = "in-mode";
      scrolling.bar = "never";
      tabs = {
        show = "switching";
        position = "left";
        last_close = "close";
      };
      colors.webpage.darkmode.enabled = true;
      colors.tabs = let
        selected = lib.mkForce (translucent 0.5 "base00");
      in {
        # The bar carries the tint and unselected tabs sit transparent on top of
        # it, so the two do not stack into near-opacity. The selected tab is a
        # darker tint at half alpha, which composites with the bar to about
        # 0.93 -- still see-through, but clearly picked out against base01.
        bar.bg = lib.mkForce (translucent opacity.desktop "base00");
        odd.bg = lib.mkForce "transparent";
        even.bg = lib.mkForce "transparent";
        selected.odd.bg = selected;
        selected.even.bg = selected;
      };
      editor.command = ["alacritty" "--class" "hover" "-e" "nvim" "+startinsert" "{}"];
      session.lazy_restore = true;
      completion.shrink = true;
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
      })
      // {
        "file:///tmp/aerc-*".content.local_content_can_access_remote_urls = true;
      };
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
