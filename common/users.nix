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

  userConfigs = (map
    (x: {
      users.users.${x} = (import ../users/${x}/user.nix { inherit config pkgs lib; username = x; })
        //
        {
          openssh.authorizedKeys.keys = [
            (lib.mkIf (userKeys.${x} ? ${config.networking.hostName}) userKeys.${x}.${config.networking.hostName} )
          ];
        };

      users.groups.${x} = {};

      home-manager.users.${x} = { pkgs, ...}: {
        imports = [ ../users/${x}/home-manager/home.nix ];
        home.stateVersion = config.system.stateVersion;
      };
    })
    allUsers
  );
in
lib.mkMerge ( [{
  #warnings = lib.mkIf (!checkKey) [
  #  "User 'lsanche' does not have valid login ssh key for hostname '${config.networking.hostName}'"
  #];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
  programs.fuse.userAllowOther = true;
  users.groups.media = {};

}] ++ userConfigs)