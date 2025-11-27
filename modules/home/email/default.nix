{
  config,
  pkgs,
  ...
}: let
  updateScript = pkgs.writeShellScriptBin "update-email" ''
    echo "Display is $DISPLAY"
    echo "Wayland Display is $WAYLAND_DISPLAY"
    if [ "x$DISPLAY" != "x" ] || [ "w$WAYLAND_DISPLAY" != "w" ]; then
      echo "Telling Astroid we are polling"
      ${pkgs.astroid}/bin/astroid --start-polling 2>&1 >/dev/null
      astroidCode=$?
    fi

    ${config.programs.mujmap.package}/bin/mujmap -C ${config.home.homeDirectory}/Maildir/fastmail sync
    returnCode=$?

    if [ "x$DISPLAY" != "x" ] || [ "w$WAYLAND_DISPLAY" != "w" ]; then

      if [ $astroidCode != 0 ]; then
        echo "Astroid was not running previously, call refresh in case it has opened since then."
        ${pkgs.astroid}/bin/astroid --refresh 0 2>&1 >/dev/null
      else
        echo "Telling Astroid we are done polling"
        ${pkgs.astroid}/bin/astroid --stop-polling 2>&1 >/dev/null
      fi
    fi

    exit "$returnCode"
  '';
in {
  systemd = {
    user = {
      services = {
        refresh-email = {
          Unit = {
            Description = "Refresh Emails";
          };
          Service = {
            ExecStart = "${updateScript}/bin/update-email";
          };
        };
      };
      timers = {
        refresh-email = {
          Unit = {
            Description = "Refresh Emails";
          };
          Timer = {
            OnCalendar = "*:0/5";
          };
          Install = {
            WantedBy = ["timers.target"];
          };
        };
      };
    };
  };
}
