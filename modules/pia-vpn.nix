
{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.pia-vpn;
in
{
  options = {
      modules = {
          pia-vpn = {
              enable = mkOption {type = types.bool; default = false; };
          };
      };
  };

  config = mkIf cfg.enable {
    services.openvpn.servers = {
        pia-vancouver = {
            autoStart = false;
            config = "config /etc/nixos/vpn/pia-vancouver.ovpn";
        };
    };
  };
}
