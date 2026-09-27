{inputs}: let
  inherit (inputs.nixpkgs) lib;
in
  lib.composeManyExtensions (with inputs; [
    llm-agents.overlays.shared-nixpkgs
    (final: _: {
      inherit (final.llm-agents) claude-desktop claude-code;
    })
  ])
