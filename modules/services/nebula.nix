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
      value = (import ../../hosts/${x}/info.nix).nebula;
    })
    allHosts
  );
  lighthouses = nebula: remove null (lib.mapAttrsToList (name: value:
    checkIfInNebula nebula value (if (value.${nebula}.isLighthouse) then name else null)) hostMap);
  externalHosts = nebula: remove null (lib.mapAttrsToList (name: value: 
    checkIfInNebula nebula value (if (value.${nebula} ? externalAddress) then name else null)) hostMap);
  relays = nebula: remove null (lib.mapAttrsToList (name: value:
    checkIfInNebula nebula value (if (value.${nebula}.isRelay) then name else null)) hostMap);
  checkIfInNebula = (nebula: host: function: if (host ? ${nebula}) then function else null);
  nebulae = {
    matrix = {
      hosts = [ "oracle" "morpheus" "neo" "trinity" ];
      #lighthouses = lighthouses "matrix";
      #externalHosts = externalHosts "matrix";
      #relays = relays "matrix";
    };
  };
in {
  options.modules.services.nebula = {
    enable = mkEnableOption "Nebula";
  };

  config = let
    hostName = config.networking.hostName;
  in mkIf (cfg.enable && config.networking.hostName != null) {
    age.secrets = let
      getNebulaSecret = name: ../../secrets + "/${hostName}" + /${name};
    in {
      nebula-ca-crt.file = ../../secrets/nebula.ca.crt.age;
      nebula-crt.file = getNebulaSecret "nebula.crt.age";
      nebula-key.file = getNebulaSecret "nebula.key.age";
    };

    networking.hosts = lib.mapAttrs' (name: value:
      lib.nameValuePair (value.matrix.ip) ([ "${name}.matrix" ]) ) hostMap;
  
    services.nebula.networks = with config.age.secrets; builtins.mapAttrs (currentNebula: value: {
        key = nebula-key.path;
        cert = nebula-crt.path;
        ca = nebula-ca-crt.path;
        lighthouses = map (x: hostMap.${x}.${currentNebula}.ip) (lighthouses currentNebula);
        isLighthouse = value.isLighthouse;
        staticHostMap = builtins.listToAttrs (map
          (x: {
            name = "${hostMap.${x}.${currentNebula}.ip}";
            value = [ hostMap.${x}.${currentNebula}.externalAddress ];
          })
          (externalHosts currentNebula)
        );
        settings = {
          relay = if value.isLighthouse then {
            am_relay = true;
          } else {
            relays = map (x: hostMap.${x}.${currentNebula}.ip ) (relays currentNebula);
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
      }) hostMap.${hostName};
  };
}
