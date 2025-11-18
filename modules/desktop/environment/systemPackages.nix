{
  pkgs,
  inputs,
}:
with pkgs; [
  #pkgs.kdiskmark
  #rustdesk-flutter
  inputs.ppd.packages.${system}.default
  man-pages
]
