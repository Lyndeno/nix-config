# meta.description = "Declares the hostMeta options consumed by the README generator"
{lib, ...}: {
  options.hostMeta = {
    description = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        One-line description of this host's purpose. Consumed by the README
        generator (packages/readme.nix) to build the Hosts section.
      '';
    };

    specs = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Hardware / specs summary for this host, as Markdown (may be a bullet
        list). Consumed by the README generator.
      '';
    };
  };
}
