{
  config,
  pkgs,
}: let
  updateScript = pkgs.writeShellScriptBin "update-email" ''
    if [ "x$DISPLAY" != "x" ]
      echo "Telling Astroid we are polling"
      then ${pkgs.astroid}/bin/astroid --start-polling 2>&1 >/dev/null
    fi

    ${config.programs.mujmap.package}/bin/mujmap -C ${config.home.homeDirectory}/Maildir/fastmail sync
    returnCode=$?

    if [ "x$DISPLAY" != "x" ]
      echo "Telling Astroid we are done polling"
      then ${pkgs.astroid}/bin/astroid --stop-polling 2>&1 >/dev/null
    fi

    exit "$returnCode"
  '';
in {
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
}
