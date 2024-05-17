{
  pkgs,
  inputs,
}: {
  polarity = "dark";
  cursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };
  fonts = let
    cascadia = pkgs.nerdfonts.override {fonts = ["CascadiaCode"];};
  in {
    serif = {
      package = inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd;
      name = "SFProDisplay Nerd Font";
    };
    sansSerif = {
      package = inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd;
      name = "SFProDisplay Nerd Font";
    };
    monospace = {
      package = cascadia;
      name = "CaskaydiaCove Nerd Font Mono";
    };
  };
}
