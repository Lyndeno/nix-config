{
  config,
  pkgs,
  lib,
  ...
}: {
  home-manager.users.lsanche = {
    systemd.user = with config.lib.stylix.colors.withHashtag; {
      services.wob = {
        Unit = {
          Description = "A lightweight overlay volume/backlight/progress/anything bar for Wayland";
          Documentation = ["man:wob(1)"];
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };
        Service = {
          StandardInput = "socket";
          ExecStart = "${pkgs.wob}/bin/wob";
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
      sockets.wob = {
        Socket = {
          ListenFIFO = "%t/wob.sock";
          SocketMode = "0600";
          RemoveOnStop = "on";
          FlushPending = "yes";
        };
        Install = {
          WantedBy = ["sockets.target"];
        };
      };
    };
    home.file.wobConfig = with config.lib.stylix.colors; {
      target = ".config/wob/wob.ini";
      text = ''
        bar_color = ${base07}FF
        border_color = ${base07}FF
        background_color = ${base01}FF
        anchor = bottom
        margin = 30
      '';
    };
  };
}
