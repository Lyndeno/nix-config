{osConfig}: {
  inherit (osConfig.modules.desktop) enable;
  settings = {
    git_protocol = "ssh";
  };
}
