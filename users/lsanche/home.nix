{
  config,
  pkgs,
  isDesktop ? false,
  desktopEnv ? "",
  stateVersion,
  inputs,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  # Pass more args to "import"
  _module.args = {
    inherit isDesktop inputs desktopEnv;
  };
  # Import all files in "home"
  imports = let
    lslib = import ../../lslib.nix;
  in
    lslib.lsPaths ./home;

  home = {
    username = "lsanche";
    homeDirectory = "/home/lsanche";
    enableNixpkgsReleaseCheck = true;

    packages = with pkgs; [
      neofetch
      bottom
    ];
  };

  programs = {
    bottom.enable = true;

    nnn = {
      enable = true;
      package = pkgs.nnn.override {withNerdIcons = true;};
      plugins.src = config.programs.nnn.package.src + "/plugins";
    };
  };

  xdg = {
    enable = true;
    userDirs.enable = true;
    userDirs.createDirectories = true;
  };

  home.sessionVariables = {
    EDITOR = "vim";
    MANPAGER = "sh -c '${pkgs.util-linux}/bin/col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  };

  nixpkgs.config.allowUnfree = true;

  home.stateVersion = stateVersion;
}
