{
  imports = [
    ./common.nix
    ./host/configuration.nix
    ./host/hardware.nix
    ./modules/desktop.nix
    ./modules/services/pia-vpn.nix
    ./modules/services/torrents.nix
    ./modules/programs/gaming.nix
    ./modules/services/snapper-home.nix
    ./modules/printers.nix
  ];
}
