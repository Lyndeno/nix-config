{
  pkgs,
  inputs,
}: {
  systemPackages = with pkgs; [
    git
    screen
    inputs.ironfetch.packages.${stdenv.hostPlatform.system}.default
  ];
}
