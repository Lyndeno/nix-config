{lib}: {
  enable = true;
  enableTransience = true;
  settings = {
    add_newline = false;

    format = lib.concatStrings [
      "$username$hostname$directory\n"
      "$battery"
      "$jobs"
      "$memory_usage"
      "$git_branch"
      "$git_status"
      "$rust"
      "$cmake"
      "$cmd_duration"
      "$nix_shell"
      "$character"
    ];

    cmd_duration = {
      min_time = 10000;
      format = "[$duration]($style) ";
      show_notifications = true;
      #cmd_duration.notification_timeout = 3000;
    };

    cmake = {
      format = "[$symbol]($version)]($style) ";
      style = "bold cyan";
    };

    hostname.format = "@[$hostname](bold yellow):";

    directory = {
      truncation_symbol = ".../";
      truncation_length = 5;
    };

    memory_usage = {
      disabled = true;
      threshold = 50;
    };

    git_branch.format = "[$symbol$branch]($style) ";

    jobs.symbol = " ";

    username = {
      format = "[$user]($style)";
      style_user = "bold green";
    };
  };
}
