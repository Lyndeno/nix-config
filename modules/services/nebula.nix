{config, lib, pkgs, ...}:

with lib;

# This file defines the nebula mesh that all my Nix machines will use
# This it to cleanup the config and remove duplicate information whenever possible

let
  allHosts = builtins.attrNames (builtins.readDir ../../hosts);
  cfg = config.modules.services.nebula;
  hostMap = builtins.listToAttrs (map
    (x: {
      name = x;
      value = (import ../../hosts/${x}/info.nix).nebula.matrix;
    })
    allHosts
  );
  lighthouses = remove null (lib.mapAttrsToList (name: value:
    if (value.isLighthouse) then name else null) hostMap);
  externalHosts = remove null (lib.mapAttrsToList (name: value: 
    if (value ? externalAddress) then name else null) hostMap);
  relays = remove null (lib.mapAttrsToList (name: value:
    if (value.isRelay) then name else null) hostMap);
in {
  options.modules.services.nebula = {
    enable = mkEnableOption "Nebula";
  };

  config = mkIf (cfg.enable && config.networking.hostName != null) {
    age.secrets = let
      getNebulaSecret = name: ../../secrets + "/${config.networking.hostName}" + /${name};
    in {
      nebula-ca-crt.file = ../../secrets/nebula.ca.crt.age;
      nebula-crt.file = getNebulaSecret "nebula.crt.age";
      nebula-key.file = getNebulaSecret "nebula.key.age";
    };

    networking.hosts = lib.mapAttrs' (name: value:
      lib.nameValuePair (value.ip) ([ "${name}.matrix" ]) ) hostMap;
  
    services.nebula.networks = with config.age.secrets; {
      matrix = {
        key = nebula-key.path;
        cert = nebula-crt.path;
        ca = nebula-ca-crt.path;
        #lighthouses = [ "10.10.10.1" ];
        lighthouses = map (x: hostMap.${x}.ip) lighthouses;
        isLighthouse = hostMap.${config.networking.hostName}.isLighthouse;
        staticHostMap = builtins.listToAttrs (map
          (x: {
            name = "${hostMap.${x}.ip}";
            value = [ hostMap.${x}.externalAddress ];
          })
          externalHosts
        );
        settings = {
          relay = if hostMap.${config.networking.hostName}.isLighthouse then {
            am_relay = true;
          } else {
            relays = map (x: hostMap.${x}.ip ) relays;
            use_relays = true;
          };
        };
        firewall = {
          inbound = [
            {
              host = "any";
              port = "any";
              proto = "any";
            }
          ];
          outbound = [
            {
              host = "any";
              port = "any";
              proto = "any";
            }
          ];
        };
      };
    };
  };
}
