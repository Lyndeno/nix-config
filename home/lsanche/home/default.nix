{
  pkgs,
  osConfig,
  config,
  super,
}: {
  username = "lsanche";
  homeDirectory = "/home/lsanche";
  enableNixpkgsReleaseCheck = true;
  shellAliases = {
    cat = "${pkgs.bat}/bin/bat";
  };
  inherit (osConfig.system) stateVersion;

  file = {
    ".config/niri/config.kdl" = {
      text = super.niri;
    };
    ".cargo/config.toml" = {
      text =
        # toml
        ''
          [build]
          target-dir = "${config.home.homeDirectory}/.cargo/target"
        '';
    };
  };
}
