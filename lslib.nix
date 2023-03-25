{lib, ...}: rec {
  # Produces an array of the file/folder names in given directory
  ls = folder: (builtins.attrNames (builtins.readDir folder));

  lsType = folder: type: (builtins.attrNames (lib.filterAttrs (_n: v: v == type) (builtins.readDir folder)));
  lsFiles = folder: lsType folder "regular";
  lsDirs = folder: lsType folder "directory";

  # Procuces an array of paths to files/folders in given directory
  lsPaths = folder: map (x: folder + "/${x}") (ls folder);
}
