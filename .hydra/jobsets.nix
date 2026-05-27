{
  nixpkgs,
  pulls,
  owner,
  repo,
  ...
}: let
  pkgs = import nixpkgs {};

  prs = builtins.fromJSON (builtins.readFile pulls);
  prJobsets =
    pkgs.lib.mapAttrs (num: info: {
      enabled = 1;
      hidden = false;
      description = "PR ${num}: ${info.title}";
      checkinterval = 300;
      schedulingshares = 20;
      enableemail = false;
      emailoverride = "";
      keepnr = 1;
      type = 1;
      flake = "github:${owner}/${repo}/pull/${num}/head";
    })
    prs;

  mkFlakeJobset = branch: schedulingshares: {
    inherit schedulingshares;
    description = "Build ${branch}";
    checkinterval = "300";
    enabled = "1";
    enableemail = false;
    emailoverride = "";
    keepnr = 1;
    hidden = false;
    type = 1;
    flake = "github:${owner}/${repo}/${branch}";
  };

  desc =
    prJobsets
    // {
      "master" = mkFlakeJobset "master" 100;
    };

  log = {
    pulls = prs;
    jobsets = desc;
  };
in {
  jobsets = pkgs.runCommand "spec-jobsets.json" {} ''
    cp ${pkgs.writeText "jobsets.json" (builtins.toJSON desc)} $out
    ${pkgs.jq}/bin/jq . ${pkgs.writeText "jobsets-log.json" (builtins.toJSON log)}
  '';
}
