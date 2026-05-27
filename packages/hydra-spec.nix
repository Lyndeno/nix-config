{
  pkgs,
  pname,
  ...
}: let
  /*
  Generate a Hydra declarative project spec (the content of .hydra/spec.json)
  for a GitHub-hosted flake repository.

  The nixexpr input points back at the same repository so that Hydra fetches
  jobsets.nix from the repo itself.  Pass `nixexprOwner`/`nixexprRepo`/
  `nixexprBranch` to override this when the jobsets evaluator lives in a
  separate CI flake.

  Arguments:
    owner          – GitHub owner of the target repo (required)
    repo           – GitHub repository name (required)
    nixpkgsValue   – git input value for nixpkgs passed to jobsets.nix
    nixexprOwner   – owner of the repo that contains jobsets.nix (defaults to owner)
    nixexprRepo    – repo  that contains jobsets.nix (defaults to repo)
    nixexprBranch  – branch to track for the nixexpr input
    nixexprPath    – path to jobsets.nix inside nixexprRepo
    checkinterval  – seconds between Hydra evaluation runs
    schedulingshares – relative scheduling weight for this jobset
  */
  mkHydraSpec = {
    owner,
    repo,
    nixpkgsValue ? "https://github.com/NixOS/nixpkgs nixos-unstable",
    nixexprOwner ? owner,
    nixexprRepo ? repo,
    nixexprBranch ? "master",
    nixexprPath ? ".hydra/jobsets.nix",
    checkinterval ? 300,
    schedulingshares ? 100,
  }: {
    inherit checkinterval schedulingshares;
    description = "Jobset evaluation for ${owner}/${repo}";
    emailoverride = "";
    enableemail = false;
    enabled = 1;
    hidden = false;
    inputs = {
      nixexpr = {
        emailresponsible = false;
        type = "git";
        value = "https://github.com/${nixexprOwner}/${nixexprRepo} ${nixexprBranch}";
      };
      nixpkgs = {
        emailresponsible = false;
        type = "git";
        value = nixpkgsValue;
      };
      owner = {
        emailresponsible = false;
        type = "string";
        value = owner;
      };
      pulls = {
        emailresponsible = false;
        type = "githubpulls";
        value = "${owner} ${repo}";
      };
      refs = {
        emailresponsible = false;
        type = "github_refs";
        value = "${owner} ${repo} heads";
      };
      repo = {
        emailresponsible = false;
        type = "string";
        value = repo;
      };
    };
    keepnr = 1;
    nixexprinput = "nixexpr";
    nixexprpath = nixexprPath;
    type = 0;
  };

  spec = mkHydraSpec {
    owner = "Lyndeno";
    repo = "nix-config";
  };
in
  pkgs.runCommand pname {
    passthru = {inherit mkHydraSpec;};
  } ''
    ${pkgs.jq}/bin/jq --sort-keys . \
      ${pkgs.writeText "spec-raw.json" (builtins.toJSON spec)} > $out
  ''
