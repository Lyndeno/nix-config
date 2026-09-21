# Verifies the committed base16-matugen.yaml matches the output of
# packages/matugen-base16.nix, i.e. that the wallpaper and the checked-in
# scheme haven't drifted apart. If this check fails, regenerate and commit.
{
  pkgs,
  perSystem,
  ...
}:
pkgs.runCommand "matugen-base16-check" {
  meta.platforms = ["x86_64-linux"];
} ''
  if ! ${pkgs.diffutils}/bin/diff -u ${../modules/nixos/stylix/base16-matugen.yaml} ${perSystem.self.matugen-base16}; then
    echo "modules/nixos/stylix/base16-matugen.yaml is out of date, run:"
    echo '  install -m 644 "$(nix build --no-link --print-out-paths .#matugen-base16)" modules/nixos/stylix/base16-matugen.yaml'
    exit 1
  fi
  touch $out
''
