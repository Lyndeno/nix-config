{pkgs}: {
  config.allowUnfree = true;

  overlays = [
    (_: super: {
      astroid = super.astroid.overrideAttrs (oldAttrs: {
        patches =
          (oldAttrs.patches or [])
          ++ [
            (pkgs.fetchpatch {
              name = "iframe_height.patch";
              url = "https://patch-diff.githubusercontent.com/raw/astroidmail/astroid/pull/747.patch";
              hash = "sha256-7yaqIGvxvuFqKfH5htkq13hrMVuSYYKY+kWL3TWofs8=";
            })
          ];
      });
    })
  ];
}
