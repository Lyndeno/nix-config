# meta.description = "Niri compositor user config (keybinds, layout)"
{
  flake,
  inputs,
  ...
}: {
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    flake.homeModules.wlroots
    inputs.nfsm-flake.homeModules.default
    ./includes.nix
  ];

  config = {
    programs.niri.includeFiles = [
      ./includes/base.kdl
      ./includes/input.kdl
      ./includes/layout.nix
      ./includes/window-rules.kdl
      ./includes/keybinds.nix
    ];

    services.hyprpaper.enable = true;

    services = {
      awww = {
        enable = true;
      };
      nfsm = {
        enable = true;
      };
    };

    systemd.user.services.awww-client = let
      awwwCfg = config.services.awww;
    in {
      Install = {
        WantedBy = [config.wayland.systemd.target];
      };

      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        Description = "awww-client";
        After = [config.wayland.systemd.target "awww.service"];
        PartOf = [config.wayland.systemd.target];
      };

      Service = {
        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe' awwwCfg.package "${awwwCfg.package.meta.mainProgram}")
          ]
          ++ [
            "img"
            pkgs.wallpaper.blurred.darken
          ]
        );
        Environment = [
          "PATH=$PATH:${lib.makeBinPath [awwwCfg.package]}"
        ];
        Restart = "on-failure";
        RestartSec = 10;
      };
    };
  };
}
