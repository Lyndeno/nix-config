{
  osConfig,
  pkgs,
}: {
  inherit (osConfig.mods.desktop) enable;
  package = pkgs.brave;
  extensions = [
    {id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";} # 1password
  ];
}
