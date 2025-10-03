{
  pkgs,
  inputs,
}: {
  systemPackages = with pkgs; [
    git
    screen
    inputs.ironfetch.packages.${system}.default
  ];
}
