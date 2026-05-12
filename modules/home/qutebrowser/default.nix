{lib, ...}: {
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
    };
    keyBindings = {
      normal = {
        "<Ctrl-e>" = lib.mkMerge [
          "config-cycle tabs.show switching always"
          "config-cycle statusbar.show in-mode always"
          "config-cycle scrolling.bar never overlay"
        ];
      };
    };
  };
}
