{
  config,
  inputs,
  pubKeys,
}: {
  useGlobalPkgs = true;
  useUserPackages = true;
  extraSpecialArgs = {
    isDesktop = config.mods.desktop.enable;
    isPlasma = config.mods.plasma.enable;
    isGnome = config.mods.gnome.enable;
    inherit inputs pubKeys;
  };
}
