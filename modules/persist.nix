{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.persist;
in
{
  options = {
      modules = {
          persist = {
              enable = mkEnableOption "Using impermanence to persist folders on a volatile root";
              commonPersist = mkOption {type = types.bool; default = true; };
              commonPersistPath =  mkOption {type = types.path; default = "/nix/persist"; };
          };
      };
  };

  config = mkIf cfg.enable {
    environment.persistence."/nix/persist" = mkIf cfg.commonPersist {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/root"
        "/etc/nixos"
        "/var/log"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };
  };
}
