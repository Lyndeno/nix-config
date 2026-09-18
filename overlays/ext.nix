{inputs}: let
  inherit (inputs.nixpkgs) lib;
in
  lib.composeManyExtensions (with inputs; [
    ironfetch.overlays.default
    apple-fonts.overlays.default
    ppd.overlays.default
    agenix.overlays.default
    vim-niri-nav.overlays.default
    llm-agents.overlays.shared-nixpkgs
  ])
