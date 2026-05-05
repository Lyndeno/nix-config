{
  flake,
  inputs,
  ...
}: {
  config,
  pkgs,
  lib,
  osConfig,
  ...
}: let
  niriConfig = pkgs.writeTextFile {
    name = "niri-config";
    text = import ./niri.nix {inherit config;};
  };
in {
  imports = [
    flake.homeModules.wlroots
    inputs.nfsm-flake.homeModules.default
  ];
  services.hyprpaper.enable = true;
  home.file.".config/niri/config.kdl" = {
    source = niriConfig;
  };

  home.checks = [
    (pkgs.runCommand "niri-validate" {} ''
      ${lib.getExe osConfig.programs.niri.package} validate -c ${niriConfig}
      touch $out
    '')
  ];

  services = {
    awww = {
      enable = true;
    };
    nfsm = {
      enable = true;
    };
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
