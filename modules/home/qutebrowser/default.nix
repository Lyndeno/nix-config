{
  lib,
  config,
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
      };
      colors.webpage.darkmode.enabled = true;
      # Temporary fix for video not working
      qt.args = ["disable-features=AcceleratedVideoDecodeLinuxGL"];
    };
    searchEngines = rec {
      ddg = "https://duckduckgo.com/?q={}";
      g = "https://google.com/search?hl=en&q={}";
      np = "https://search.nixos.org/packages?channel=unstable&query={}";
      no = "https://search.nixos.org/options?channel=unstable&query={}";
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
        "<Ctrl-/>" = "hint links spawn --detach ${lib.getExe config.programs.mpv.finalPackage} {hint-url}";
      };
    };
  };
}
