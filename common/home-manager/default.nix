{
  inputs,
  pubKeys,
  homes,
}: {
  useGlobalPkgs = true;
  useUserPackages = true;
  backupFileExtension = "bak";
  extraSpecialArgs = {
    inherit inputs pubKeys;
  };

  users = {
    inherit (homes) lsanche;
  };
}
