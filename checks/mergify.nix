{
  pkgs,
  flake,
  ...
}:
pkgs.runCommand "mergify-check" {} ''
  if ! ${pkgs.diffutils}/bin/diff -q ${flake.packages.${pkgs.system}.mergify} ${../. + "/.mergify.yml"}; then
    echo ".mergify.yml is out of date, run: nix build .#mergify && cp result .mergify.yml"
    exit 1
  fi
  touch $out
''
