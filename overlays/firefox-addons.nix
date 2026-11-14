# Rycee's Firefox addon set as pkgs.firefox-addons, built with our nixpkgs so
# allowUnfree applies (the input's own package set refuses unfree addons).
{inputs}: inputs.firefox-addons.overlays.default
