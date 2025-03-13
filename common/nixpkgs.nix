{pkgs}: {
  config.allowUnfree = true;

  overlays = [
    (_: super: {
      astroid = super.astroid.overrideAttrs (oldAttrs: {
        patches =
          (oldAttrs.patches or [])
          ++ [
            (pkgs.fetchpatch {
              name = "boost_is_regular.patch";
              url = "https://github.com/astroidmail/astroid/commit/abd84171dc6c4e639f3e86649ddc7ff211077244.patch";
              hash = "sha256-IY60AnWm18ZwrCFsOvBg76UginpMo7gXBf8GT87FqW4=";
            })
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
