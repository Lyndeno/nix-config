{inputs, ...}: {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];
  stylix = {
    enable = true;
    image = "${inputs.wallpapers}/sedona.jpg";
    base16Scheme = "${inputs.base16-schemes}/base16/gruvbox-dark-hard.yaml";
    targets = {
      plymouth.enable = false;
      nixos-icons.enable = false;
      console.enable = false;
    };
  };
}
