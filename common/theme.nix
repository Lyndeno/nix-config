{
  pkgs,
  inputs,
  ...
}: let
  base16Scheme = "${inputs.base16-schemes}/atelier-dune.yaml";
in {
  home-manager.users.lsanche.stylix.targets.swaylock.useImage = false;
  home-manager.users.lsanche.stylix.targets.vscode.enable = false;
  fonts.fonts = [inputs.apple-fonts.packages.${pkgs.system}.sf-pro];
  stylix = {
    image = "${inputs.wallpapers}/starry.jpg";
    inherit base16Scheme;
    targets.grub.enable = false;
    targets.chromium.enable = false;
    fonts = let
      cascadia = pkgs.nerdfonts.override {fonts = ["CascadiaCode"];};
    in {
      serif = {
        package = cascadia;
        name = "CaskaydiaCove Nerd Font";
      };
      sansSerif = {
        package = cascadia;
        name = "CaskaydiaCove Nerd Font";
      };
      monospace = {
        package = cascadia;
        name = "CaskaydiaCove Nerd Font Mono";
      };
    };
  };
}
