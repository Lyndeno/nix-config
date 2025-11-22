{
  pkgs,
  inputs,
}:
with pkgs; [
  #pkgs.kdiskmark
  #rustdesk-flutter
  inputs.ppd.packages.${stdenv.hostPlatform.system}.default
  man-pages
]
