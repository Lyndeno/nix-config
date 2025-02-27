{
  pkgs,
  inputs,
}: {
  systemPackages = with pkgs; [
    vim
    git
    busybox
    screen
    inputs.cfetch.packages.${system}.default
    inputs.ironfetch.packages.${system}.default
  ];
}
