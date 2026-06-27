{
  pkgs,
  system,
  flake,
}:
pkgs.mkShell {
  packages = with pkgs; [agenix statix deadnix];
  inherit (flake.checks.${system}.git-hooks) shellHook;
}
