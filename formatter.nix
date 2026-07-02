{
  pkgs,
  inputs,
  ...
}:
inputs.treefmt-nix.lib.mkWrapper pkgs {
  programs = {
    alejandra.enable = true;
    kdlfmt = {
      enable = true;
    };
  };

  settings.formatter.kdlfmt = {
    options = ["--kdl-version" "v1"];
  };
}
