# Generates README.md by splicing config-derived tables into the committed file
# between `<!-- BEGIN/END GENERATED:* -->` markers. Everything outside the
# markers is preserved. Validated against the committed README by
# checks/readme.nix (drift detection). Regenerate with:
#   install -m 644 "$(nix build --no-link --print-out-paths .#readme)" README.md
{
  pkgs,
  flake,
  ...
}: let
  inherit (pkgs) lib;

  # Extract the first `meta.description = "..."` from a file (works for both a
  # module's `# meta.description = "..."` comment and a package's real
  # `meta.description = "...";` attribute). Reading the source rather than
  # evaluating flake.packages avoids re-entering the package set from within a
  # package (which would recurse infinitely).
  descFromFile = path: let
    lines = lib.splitString "\n" (builtins.readFile path);
    matches =
      lib.filter (m: m != null)
      (map (l: builtins.match ''.*meta\.description = "(.*)".*'' l) lines);
  in
    if matches == []
    then null
    else lib.head (lib.head matches);

  # ---- modules: names from the filesystem, purpose from a top-of-file comment ----
  moduleDescription = path: let
    d = descFromFile path;
  in
    if d == null
    then throw "module ${toString path} is missing a `# meta.description = \"...\"` comment"
    else d;

  moduleNames = dir:
    lib.sort (a: b: a < b)
    (builtins.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir dir)));

  moduleTable = dir:
    lib.concatStringsSep "\n" (
      ["| Module | Purpose |" "|--------|---------|"]
      ++ map (n: "| `${n}` | ${moduleDescription (dir + "/${n}/default.nix")} |") (moduleNames dir)
    );

  # ---- packages: names from the filesystem, purpose from meta.description ----
  # Config generators are excluded — they produce committed files, not tools.
  pkgExclude = ["readme" "mergify" "hydra-spec"];

  packageNames =
    lib.sort (a: b: a < b)
    (lib.filter (n: !(lib.elem n pkgExclude))
      (map (lib.removeSuffix ".nix")
        (builtins.attrNames
          (lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".nix" n)
            (builtins.readDir ../packages)))));

  packageDescription = name: let
    d = descFromFile (../packages + "/${name}.nix");
  in
    if d == null
    then throw "package ${name} is missing a `meta.description` attribute"
    else d;

  packageTable = lib.concatStringsSep "\n" (
    ["| Package | Description |" "|---------|-------------|"]
    ++ map (n: "| `${n}` | ${packageDescription n} |") packageNames
  );

  # ---- hosts: list + details evaluated from nixosConfigurations ----
  hostNames = lib.sort (a: b: a < b) (builtins.attrNames flake.nixosConfigurations);

  hostBlock = name: let
    cfg = flake.nixosConfigurations.${name}.config;
    arch = cfg.nixpkgs.hostPlatform.system;
    desc = cfg.hostMeta.description;
    specs = lib.removeSuffix "\n" cfg.hostMeta.specs;
  in
    if desc == ""
    then throw "host ${name} is missing hostMeta.description (set it in hosts/${name}/configuration.nix)"
    else
      lib.concatStringsSep "\n" (
        ["### ${name} (`${arch}`)" "" desc]
        ++ lib.optionals (specs != "") ["" specs]
      );

  hostsSection = lib.concatStringsSep "\n\n" (map hostBlock hostNames);

  # ---- splice each block into its marked region in the committed README ----
  spliceRegion = text: marker: content: let
    b = "<!-- BEGIN GENERATED:${marker} -->";
    e = "<!-- END GENERATED:${marker} -->";
    p1 = lib.splitString b text;
    p2 = lib.splitString e (lib.elemAt p1 1);
  in
    if lib.length p1 != 2 || lib.length p2 != 2
    then throw "README.md must contain exactly one `${b}` ... `${e}` block"
    else lib.head p1 + b + "\n" + content + "\n" + e + lib.elemAt p2 1;

  final = lib.pipe (builtins.readFile ../README.md) [
    (t: spliceRegion t "hosts" hostsSection)
    (t: spliceRegion t "modules-nixos" (moduleTable ../modules/nixos))
    (t: spliceRegion t "modules-home" (moduleTable ../modules/home))
    (t: spliceRegion t "packages" packageTable)
  ];
in
  pkgs.writeText "README.md" final
