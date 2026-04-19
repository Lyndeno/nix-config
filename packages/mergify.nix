{
  pkgs,
  flake,
  pname,
  ...
}: let
  inherit (pkgs) lib;

  projectName = "nix-config";

  checkConditions = lib.concatLists (
    lib.mapAttrsToList (
      system: checks:
        lib.mapAttrsToList (
          name: _: "check-success*=ci/hydra:${projectName}:*:${system}.${name}"
        )
        checks
    )
    flake.checks
  );

  mergifyConfig = {
    pull_request_rules = [
      {
        name = "Automatically merge dependabot updates";
        conditions =
          [
            "author=dependabot[bot]"
          ]
          ++ checkConditions;
        actions.merge.method = "merge";
      }
    ];
  };
in
  (pkgs.formats.yaml {}).generate pname mergifyConfig
