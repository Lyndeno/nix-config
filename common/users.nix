{
  config,
  pkgs,
  lib,
  lsLib,
  ...
}: let
  allUsers = lsLib.ls ../users;
  userKeys = builtins.listToAttrs (
    map
    (x: {
      name = x;
      value = (import ../users/${x}/info.nix).hostAuthorizedKeys;
    })
    allUsers
  );
  checkKey = user: host: userKeys.${user} ? ${host};

  userConfigs = (
    map
    (x: {
      warnings = lib.mkIf (!(checkKey x config.networking.hostName)) [
        "User '${x}' does not have valid login ssh key for host '${config.networking.hostName}'"
      ];
      users.users.${x} =
        (import ../users/${x}/user.nix {
          inherit config pkgs lib;
          username = x;
        })
        // {
          openssh.authorizedKeys.keys = [
            (lib.mkIf (userKeys.${x} ? ${config.networking.hostName}) userKeys.${x}.${config.networking.hostName})
          ];
        };

      users.groups.${x} = {};

      home-manager.users.${x} = {pkgs, ...}: {
        imports = [../users/${x}/home-manager/home.nix];
        home.stateVersion = config.system.stateVersion;
      };
    })
    allUsers
  );
in
  lib.mkMerge ([
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
        };
        programs.fuse.userAllowOther = true;
        users.groups.media = {};
      }
    ]
    ++ userConfigs)
