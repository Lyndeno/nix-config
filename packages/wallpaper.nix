{
  inputs,
  pkgs,
  ...
}: let
  withPassthrus = drv:
    drv.overrideAttrs (_: {
      passthru = {
        blurred = withPassthrus (pkgs.runCommand "${drv.name}-blurred" {nativeBuildInputs = [pkgs.img-blur];} ''
          img-blur ${drv} $out
        '');
        darken = withPassthrus (pkgs.runCommand "${drv.name}-darken" {nativeBuildInputs = [pkgs.img-darken];} ''
          img-darken ${drv} $out
        '');
      };
    });

  base = pkgs.runCommand "wallpaper" {meta.description = "The desktop wallpaper (Sedona), with blurred and darkened variants";} ''
    ln -s ${inputs.wallpapers}/sedona.jpg $out
  '';
in
  withPassthrus base
