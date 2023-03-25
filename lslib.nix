rec {
  # Produces an array of the file/folder names in given directory
  ls = folder: (builtins.attrNames (builtins.readDir folder));

  # Procuces an array of paths to files/folders in given directory
  lsPaths = folder: map (x: folder + "/${x}") (ls folder);
}
