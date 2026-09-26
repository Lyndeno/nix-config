{
  lib,
  pkgs,
  config,
  osConfig,
  ...
} @ args: let
  cfg = config.programs.niri;

  resolveInclude = f: let
    basename = baseNameOf (toString f);
    imported = import f;
    content =
      if builtins.isFunction imported
      then imported args
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

  config = {
    home.file.".config/niri/config.kdl" = {
      source = niriConfig;
    };

    home.checks = [
      (pkgs.runCommand "niri-validate" {} ''
        ${lib.getExe osConfig.programs.niri.package} validate -c ${niriConfig}
        touch $out
      '')
    ];
  };
}
