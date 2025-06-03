{
  pkgs,
  osConfig,
  config,
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
      source = ./config.kdl;
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
