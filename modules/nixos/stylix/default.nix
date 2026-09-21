# meta.description = "System-wide Stylix theming (matugen scheme, Sedona wallpaper)"
{inputs, ...}: {pkgs, ...}: {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];
  stylix = {
    enable = true;
    image = pkgs.wallpaper;
    # Generated from the wallpaper by `pkgs.matugen-base16`, but committed
    # here (rather than referenced live) to avoid import-from-derivation:
    # reading this option's value at eval time would otherwise force
    # matugen-base16 to build/substitute before evaluation could finish.
    # Regenerate after changing the wallpaper or packages/matugen-base16.nix:
    #   install -m 644 "$(nix build --no-link --print-out-paths .#matugen-base16)" \
    #     modules/nixos/stylix/base16-matugen.yaml
    base16Scheme = ./base16-matugen.yaml;
    targets = {
      plymouth.enable = false;
      nixos-icons.enable = false;
      console.enable = false;
    };
  };
}
