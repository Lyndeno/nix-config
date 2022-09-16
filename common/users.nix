{config, pkgs, lib, ...}:
let
  allUsers = builtins.attrNames (builtins.readDir ../users);
  userKeys = builtins.listToAttrs (map
    (x: {
      name = x;
      value = (import ../users/${x}/info.nix).hostAuthorizedKeys;
    })
    allUsers
  );
in
{
  #warnings = lib.mkIf (!checkKey) [
  #  "User 'lsanche' does not have valid login ssh key for hostname '${config.networking.hostName}'"
  #];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
  programs.fuse.userAllowOther = true;

  users.users = builtins.listToAttrs (map
    (x: {
      name = x;
      value = 
        (import ../users/${x}/user.nix { inherit config pkgs lib; username = x; })
        //
        {
          openssh.authorizedKeys.keys = [
            (lib.mkIf (userKeys.${x} ? ${config.networking.hostName}) userKeys.${x}.${config.networking.hostName} )
          ];
        };
    })
    allUsers
  );

  users.groups = builtins.listToAttrs (map
    (x: {
      name = x;
      value = {};
    })
    allUsers
  ) // {
    media = {};
  };

  home-manager.users = builtins.listToAttrs (map
    (x: {
      name = x;
      value = { pkgs, ...}: {
        imports = [ ../users/${x}/home-manager/home.nix ];
        home.stateVersion = config.system.stateVersion;
      };
    })
    allUsers
  );
}