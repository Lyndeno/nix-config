{
  pkgs,
  inputs,
}: {
  systemPackages = with pkgs; [
    vim
    git
    busybox
    screen
    inputs.ironfetch.packages.${system}.default
    inputs.ppd.packages.${system}.default
  ];
}
