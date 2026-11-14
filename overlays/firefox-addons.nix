# Rycee's Firefox addon set as pkgs.firefox-addons, built via NUR's overlay so
# our nixpkgs config applies (NUR's own package set refuses unfree addons).
{inputs}: let
  inherit (inputs.nixpkgs) lib;
in
  lib.composeManyExtensions [
    inputs.nur.overlays.default
    (final: _: {
      inherit (final.nur.repos.rycee) firefox-addons;
    })
  ]
