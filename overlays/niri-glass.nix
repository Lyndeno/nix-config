# Niri-glass (github:zaroutt/Niri-glass) adds a liquid-glass/refraction
# background effect to niri. Its own overlay only exposes `niri-glass`, so
# compose it with an alias that puts the fork in niri's place -- the NixOS
# module's `programs.niri.package` and every other `pkgs.niri` reference then
# pick it up with no further wiring.
{inputs}:
inputs.nixpkgs.lib.composeExtensions
inputs.niri-glass.overlays.default
(final: _: {
  niri = final.niri-glass;
})
