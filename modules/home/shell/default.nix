{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];

  home = {
    shellAliases = {
      cat = "${pkgs.bat}/bin/bat";
    };
    packages = with pkgs; [
      ripgrep
    ];
    sessionVariables = {
      # TODO: For some reason bat cannot theme man pages with custom themes, so we unset here
      MANPAGER = "sh -c '${pkgs.util-linux}/bin/col -bx | BAT_THEME= ${pkgs.bat}/bin/bat -l man -p'";
      MANROFFOPT = "-c";
    };
  };

  programs = {
    command-not-found.enable = false;
    bottom.enable = true;
    fzf.enable = true;
    nix-index-database.comma.enable = true;
    nix-index.enable = true;

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';
      binds = {
        "ctrl-space".command = "accept-autosuggestion";
      };
      shellAbbrs = {
        gpf = "git push --force-with-lease";
        gca = "git commit --amend";
        gp = "git push";
        nfb = "nix-fast-build";
      };
    };

    atuin = {
      enable = true;
      settings = {
        sync = {
          records = true;
        };
      };
      daemon.enable = true;
      flags = [
        "--disable-up-arrow"
      ];
    };

    bat = {
      enable = true;
      extraPackages = [pkgs.bat-extras.batman];
    };

    eza = {
      enable = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "-B"
      ];
    };

    less = {
      enable = true;
      config = ''
        #command
        / forw-search ^W
        ? back-search ^W
      '';
    };

    starship = {
      enable = true;
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

        right_format = lib.concatStrings [
          "$all"
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
    };
  };
}
