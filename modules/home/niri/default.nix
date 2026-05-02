{flake, ...}: {
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    flake.homeModules.wlroots
  ];
  services.hyprpaper.enable = true;
  home.file.".config/niri/config.kdl" = {
    text = import ./niri.nix {inherit config;};
  };

  services.awww = {
    enable = true;
  };

  systemd.user.services.awww-client = let
    cfg = config.services.awww;

    old = config.stylix.image;

    blurred = pkgs.runCommand "blurred-wallpaper" {} ''
      ${pkgs.imagemagick}/bin/magick ${old} -blur 0x50 -modulate 40 $out
    '';
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
          (lib.getExe' cfg.package "${cfg.package.meta.mainProgram}")
        ]
        ++ [
          "img"
          blurred
        ]
      );
      Environment = [
        "PATH=$PATH:${lib.makeBinPath [cfg.package]}"
      ];
      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}
