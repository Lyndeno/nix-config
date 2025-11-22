{
  pkgs,
  system,
  flake,
  perSystem,
}:
pkgs.mkShell {
  packages = with pkgs; [perSystem.agenix.default statix deadnix];
  inherit (flake.checks.${system}.git-hooks) shellHook;
}
