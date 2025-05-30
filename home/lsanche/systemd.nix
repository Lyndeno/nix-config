{config}: {
  user = {
    services = {
      mujmap = {
        Unit = {
          Description = "Run mujmap";
        };
        Service = {
          ExecStart = "${config.programs.mujmap.package}/bin/mujmap -C /home/lsanche/Maildir/fastmail sync";
        };
      };
    };
    timers = {
      mujmap = {
        Unit = {
          Description = "Run mujmap";
        };
        Timer = {
          OnCalendar = "hourly";
        };
      };
    };
  };
}
