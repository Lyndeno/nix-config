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
  inherit (pkgs.stdenv.hostPlatform) system;
  cfg = config.programs.niri;

  nixArgs = {
    inherit pkgs lib config;
    vim-niri-nav = lib.getExe inputs.vim-niri-nav.packages.${system}.vim-niri-nav;
  };

  resolveInclude = f: let
    basename = builtins.baseNameOf (builtins.toString f);
    imported = import f;
    content =
      if builtins.isFunction imported
      then imported nixArgs
      else imported;
  in
    if lib.hasSuffix ".nix" basename
    then pkgs.writeText "${lib.removeSuffix ".nix" basename}.kdl" content
    else f;

  includeStatements =
    lib.concatMapStrings (f: ''
      include "${resolveInclude f}"
    '')
    cfg.includeFiles;

  niriConfig = pkgs.writeTextFile {
    name = "niri-config";
    text = includeStatements;
  };
in {
  options.programs.niri.includeFiles = lib.mkOption {
    type = lib.types.listOf lib.types.path;
    default = [];
    description = ''
      Paths to KDL files or Nix files (evaluating to strings) to include in
      the niri config via the include directive. Nix files are imported and
      their string result is written to the store before being referenced.
    '';
  };

  imports = [
    flake.homeModules.wlroots
    inputs.nfsm-flake.homeModules.default
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
      awwwCfg = config.services.awww;

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
            (lib.getExe' awwwCfg.package "${awwwCfg.package.meta.mainProgram}")
          ]
          ++ [
            "img"
            blurred
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
