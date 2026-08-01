# Verifies the committed README.md matches the output of packages/readme.nix.
# If this check fails, regenerate the README from the package and commit it.
{
  pkgs,
  perSystem,
  ...
}:
pkgs.runCommand "readme-check" {
  meta.platforms = ["x86_64-linux"];
} ''
  if ! ${pkgs.diffutils}/bin/diff -u ${../README.md} ${perSystem.self.readme}; then
    echo "README.md is out of date, run:"
    echo '  install -m 644 "$(nix build --no-link --print-out-paths .#readme)" README.md'
    exit 1
  fi
  touch $out
''
