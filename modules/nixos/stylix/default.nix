# meta.description = "System-wide Stylix theming (Gruvbox Dark Hard, Sedona wallpaper)"
{inputs, ...}: {pkgs, ...}: {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];
  stylix = {
    enable = true;
    image = pkgs.wallpaper;
    base16Scheme = "${pkgs.matugen-base16}";
    targets = {
      plymouth.enable = false;
      nixos-icons.enable = false;
      console.enable = false;
    };
  };
}
