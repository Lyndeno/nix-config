{
  lib,
  config,
}: {
  cpuFreqGovernor = lib.warn "Change governor back to only powersave once kernel is back to 6.3" (lib.mkDefault (
    if (builtins.elem "amd_pstate=active" config.boot.kernelParams)
    then "powersave"
    else "ondemand"
  ));
}
