{
  pkgs,
  perSystem,
  ...
}:
pkgs.runCommand "hydra-spec-check" {} ''
  if ! ${pkgs.diffutils}/bin/diff -q ${perSystem.self.hydra-spec} ${../.hydra/spec.json}; then
    echo ".hydra/spec.json is out of date, run:"
    echo "  nix build .#hydra-spec && cp result .hydra/spec.json"
    exit 1
  fi
  touch $out
''
