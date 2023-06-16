{
  config,
  pkgs,
  lib,
  lsLib,
  inputs,
  hostName,
  ...
}: let
  allUsers = lsLib.lsDirs ./.;
  userExcludes = builtins.listToAttrs (
    map
    (x: {
      name = x;
      value = let
        i = import ./${x}/info.nix;
      in
        if (i ? excludeHosts)
        then builtins.elem hostName i.excludeHosts
        else false;
    })
    allUsers
  );
  userKeys = builtins.listToAttrs (
    map
    (x: {
      name = x;
      value = (import ./${x}/info.nix).hostAuthorizedKeys;
    })
    allUsers
  );
  checkKey = user: host: userKeys.${user} ? ${host};
  localUsers = builtins.filter (x: !userExcludes.${x}) allUsers;

  userConfigs =
    map
    (x: {
      warnings = lib.mkIf (!(checkKey x config.networking.hostName)) [
        "User '${x}' does not have valid login ssh key for host '${config.networking.hostName}'"
      ];
      users.users.${x} =
        (import ./${x}/user.nix {
          inherit config pkgs lib;
          username = x;
        })
        // {
          openssh.authorizedKeys.keys = [
            (lib.mkIf (userKeys.${x} ? ${config.networking.hostName}) userKeys.${x}.${config.networking.hostName})
          ];
        };

      users.groups.${x} = {};

      home-manager.users.${x} = lib.mkIf (builtins.pathExists ./${x}/home.nix) (import ./${x}/home.nix {
        config = config.home-manager.users.${x};
        inherit pkgs lib inputs lsLib;
        isDesktop = config.mods.desktop.enable;
        inherit (config.system) stateVersion;
      });
    })
    localUsers;
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
