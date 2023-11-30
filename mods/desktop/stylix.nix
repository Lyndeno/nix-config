{
  pkgs,
  inputs,
}: {
  polarity = "dark";
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
