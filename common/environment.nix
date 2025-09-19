{
  pkgs,
  inputs,
}: {
  systemPackages = with pkgs; [
    neovim
    git
    screen
    inputs.ironfetch.packages.${system}.default
  ];
}
