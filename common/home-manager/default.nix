{
  inputs,
  flakeLib,
  homes,
}: {
  useGlobalPkgs = true;
  useUserPackages = true;
  backupFileExtension = "bak";
  extraSpecialArgs = {
    inherit inputs flakeLib;
  };

  users = {
    inherit (homes) lsanche;
  };
}
