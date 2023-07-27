{
  pkgs,
  inputs,
}: {
  systemPackages = with pkgs; [
    prismlauncher
    dolphin-emu-beta
    inputs.nix-gaming.packages.${pkgs.system}.faf-client
  ];
}
