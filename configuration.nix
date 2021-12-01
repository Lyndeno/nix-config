{
  imports = [
    ./common.nix
    ./host/configuration.nix
    ./host/hardware.nix
    ./modules/desktop.nix
    ./modules/pia-vpn.nix
    ./modules/torrents.nix
    ./modules/gaming.nix
    ./services/snapper-home.nix
  ];
}
