{ config, lib, pkgs, inputs, ...}:
{
  warnings = lib.mkIf (!checkKey) [
    "User 'lsanche' does not have valid login ssh key for hostname '${config.networking.hostName}'"
  ];
  }
