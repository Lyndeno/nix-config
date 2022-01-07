{
  imports = [
    <home-manager/nixos>
    <impermanence/nixos.nix>
    ./common.nix
    ./users
    ./host/configuration.nix
    ./host/hardware.nix
    ./modules
  ];
}
