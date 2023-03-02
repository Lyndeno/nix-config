{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.printers;
in {
  options = {
    modules = {
      printers = {
        canon = {
          pixma = {
            mx860 = {
              enable = mkOption {
                type = types.bool;
                default = false;
              };
            };
          };
        };
      };
    };
  };

  config = {
    services.printing.drivers = with cfg; (mkMerge [
      (mkIf canon.pixma.mx860.enable [pkgs.gutenprint pkgs.cups-bjnp])
    ]);
  };
}
