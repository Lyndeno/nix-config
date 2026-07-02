{
  system,
  inputs,
  perSystem,
  ...
}:
inputs.git-hooks.lib.${system}.run {
  src = ../.;
  hooks = {
    treefmt = {
      enable = true;
      package = perSystem.self.formatter;
    };
    statix.enable = true;
    deadnix.enable = true;
  };
}
