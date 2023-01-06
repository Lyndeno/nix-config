{pkgs, lib, inputs, ...}:
let
  base16Scheme = "${inputs.base16-schemes}/atelier-dune.yaml";
in {
    stylix = {
      image = "${inputs.wallpapers}/starry.jpg";
      base16Scheme = base16Scheme;
      targets.swaylock.useImage = false;
      targets.grub.enable = false;
      fonts = let
        cascadia = (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" ]; });
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
