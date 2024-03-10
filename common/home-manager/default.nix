{
  inputs,
  pubKeys,
  homes,
}: {
  useGlobalPkgs = true;
  useUserPackages = true;
  extraSpecialArgs = {
    inherit inputs pubKeys;
  };

  users.lsanche = homes.lsanche;
}
