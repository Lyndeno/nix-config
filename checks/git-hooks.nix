{
  system,
  inputs,
  ...
}:
inputs.git-hooks.lib.${system}.run {
  src = ../.;
  hooks = {
    alejandra.enable = true;
    statix.enable = true;
    deadnix.enable = true;
  };
}
