{inputs, ...}: {
  # Auto-discovered nixpkgs patches, applied to nixpkgs.<pkg>:
  #   patches/<pkg>.patch    - a patch file, used as-is.
  #   patches/<pkg>.nix      - an attrset with (at least) `url` and `hash`,
  #                            passed to fetchpatch. `name` defaults to the
  #                            file's basename (e.g. "<pkg>") but can be
  #                            overridden by the attrset itself.
  #   patches/<pkg>/*.patch  - same as above, multiple patches per package.
  #   patches/<pkg>/*.nix
  patchOverlayFromDir = patchesDir: let
    inherit (inputs.nixpkgs) lib;
    isPatchFile = name: type: type == "regular" && lib.hasSuffix ".patch" name;
    isSpecFile = name: type: type == "regular" && lib.hasSuffix ".nix" name;

    # Entries for the files directly inside `dir`, each defaulting `pkg`
    # (and, for specs, `name`) to its own basename without extension.
    entriesIn = dir:
      lib.concatLists
      (lib.mapAttrsToList (
          name: type:
            if isPatchFile name type
            then [
              {
                kind = "file";
                path = dir + "/${name}";
                pkg = lib.removeSuffix ".patch" name;
              }
            ]
            else if isSpecFile name type
            then [
              {
                kind = "spec";
                path = dir + "/${name}";
                name = lib.removeSuffix ".nix" name;
                pkg = lib.removeSuffix ".nix" name;
              }
            ]
            else []
        )
        (builtins.readDir dir));

    patchList =
      lib.concatLists
      (lib.mapAttrsToList (
          name: type:
            if type == "directory"
            then map (entry: entry // {pkg = name;}) (entriesIn (patchesDir + "/${name}"))
            else []
        )
        (builtins.readDir patchesDir))
      ++ entriesIn patchesDir;

    groupedPatches =
      lib.foldl'
      (acc: entry: acc // {${entry.pkg} = (acc.${entry.pkg} or []) ++ [entry];})
      {}
      patchList;

    toPatch = prev: entry:
      if entry.kind == "file"
      then entry.path
      else prev.fetchpatch ({inherit (entry) name;} // import entry.path);

    patchOverlay = _final: prev:
      lib.mapAttrs (
        pkg: entries:
          prev.${pkg}.overrideAttrs (old: {
            patches = (old.patches or []) ++ map (toPatch prev) entries;
          })
      )
      groupedPatches;
  in
    patchOverlay;

  # Auto-discovered overlays: every overlays/*.nix file is imported and used as
  # an overlay. If its outer argument is an attrset pattern requiring `inputs`
  # (e.g. `{inputs}: final: prev: ...`), it's called with `{inherit inputs;}`
  # first; otherwise the imported value is used directly as the `final: prev:`
  # overlay.
  overlaysFromDir = overlaysDir: let
    inherit (inputs.nixpkgs) lib;
    isOverlayFile = name: type: type == "regular" && lib.hasSuffix ".nix" name;

    toOverlay = name: _type: let
      imported = import (overlaysDir + "/${name}");
    in
      if builtins.functionArgs imported ? inputs
      then imported {inherit inputs;}
      else imported;
  in
    lib.mapAttrsToList toOverlay
    (lib.filterAttrs isOverlayFile (builtins.readDir overlaysDir));
}
