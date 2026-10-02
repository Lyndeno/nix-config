# Initial version of this file found at:
# https://github.com/NixOS/nixpkgs/issues/377827#issuecomment-2624618017
{
  config,
  lib,
  ...
}: let
  # mkDefault is 1000
  # assignment is 100
  # This ensures that service defaults are overwritten, while
  # giving the administrator a chance to just override by assigning.
  mkDefaulter = lib.mkOverride 999;
in {
  options = {
    systemd.services = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          {config, ...}: {
            options = {
              sandbox = lib.mkOption {
                description = ''
                  Level of confinement for this particular unit.

                  0 is no confinement at all.
                  2 is the current state of confinement. Requires systemd >= 245.
                '';
                default = 0;
                type = lib.types.enum [
                  0
                  2
                ];
              };

              allowImplicitRoot = lib.mkOption {
                description = "Whether or not the fact that this unit is running as root should be ignored.";
                type = lib.types.bool;
                default = false;
                example = true;
              };
            };

            config = lib.mkMerge [
              (lib.mkIf (config.sandbox >= 2) {
                serviceConfig = lib.mapAttrs (_: mkDefaulter) {
                  # Filesystem stuff
                  ProtectSystem = "strict"; # Prevent writing to most of /
                  ProtectHome = true; # Prevent accessing /home and /root
                  PrivateTmp = true; # Give an own directory under /tmp
                  PrivateDevices = true; # Deny access to most of /dev
                  ProtectKernelTunables = true; # Protect some parts of /sys
                  ProtectControlGroups = true; # Remount cgroups read-only
                  RestrictSUIDSGID = true; # Prevent creating SETUID/SETGID files
                  PrivateMounts = true; # Give an own mount namespace
                  RemoveIPC = true;
                  UMask = "0077";

                  # Capabilities
                  CapabilityBoundingSet = ""; # Allow no capabilities at all
                  NoNewPrivileges = true; # Disallow getting more capabilities. This is also implied by other options.

                  # Kernel stuff
                  ProtectKernelModules = true; # Prevent loading of kernel modules
                  SystemCallArchitectures = "native"; # Usually no need to disable this
                  ProtectKernelLogs = true; # Prevent access to kernel logs
                  ProtectClock = true; # Prevent setting the RTC

                  # Networking
                  RestrictAddressFamilies = ""; # Example: "AF_UNIX AF_INET AF_INET6"
                  PrivateNetwork = true; # Isolate the entire network

                  # Misc
                  LockPersonality = true; # Prevent change of the personality
                  ProtectHostname = true; # Give an own UTS namespace
                  RestrictRealtime = true; # Prevent switching to RT scheduling
                  MemoryDenyWriteExecute = true; # Maybe disable this for interpreters like python
                  PrivateUsers = true; # If anything randomly breaks, it's mostly because of this
                  RestrictNamespaces = true;
                };
              })
            ];
          }
        )
      );
    };
  };

  config.warnings =
    lib.mapAttrsToList
    (k: _: "${k}.service is running as implicit root, this should not be done in production.")
    (
      lib.filterAttrs (
        _: v:
          v.sandbox
          != 0
          && !v.allowImplicitRoot
          && !(v.serviceConfig ? User)
          && ((v.serviceConfig ? DynamicUser) -> !v.serviceConfig.DynamicUser)
      )
      config.systemd.services
    )
    ++ lib.mapAttrsToList (k: _: "${k}.service has no system call filter.") (
      lib.filterAttrs (
        _: v: v.sandbox != 0 && !(v.serviceConfig ? SystemCallFilter)
      )
      config.systemd.services
    );
}
