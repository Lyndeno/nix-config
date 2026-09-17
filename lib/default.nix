{inputs, ...}: {
  # Auto-discovered nixpkgs patches. Each ./patches/<pkg>.patch, or each
  # *.patch file inside ./patches/<pkg>/, is applied to nixpkgs.<pkg>.
  patchOverlayFromDir = patchesDir: let
    inherit (inputs.nixpkgs) lib;
    isPatchFile = name: type: type == "regular" && lib.hasSuffix ".patch" name;
    patchList =
      lib.concatLists
      (lib.mapAttrsToList (
          name: type:
            if isPatchFile name type
            then [
              {
                pkg = lib.removeSuffix ".patch" name;
                path = patchesDir + "/${name}";
              }
            ]
            else if type == "directory"
            then
              map (file: {
                pkg = name;
                path = patchesDir + "/${name}/${file}";
              })
              (lib.attrNames (lib.filterAttrs isPatchFile (builtins.readDir (patchesDir + "/${name}"))))
            else []
        )
        (builtins.readDir patchesDir));
    groupedPatches =
      lib.foldl'
      (acc: entry: acc // {${entry.pkg} = (acc.${entry.pkg} or []) ++ [entry.path];})
      {}
      patchList;
    patchOverlay = _final: prev:
      lib.mapAttrs (
        pkg: patches:
          prev.${pkg}.overrideAttrs (old: {
            patches = (old.patches or []) ++ patches;
          })
      )
      groupedPatches;
  in
    patchOverlay;
}
