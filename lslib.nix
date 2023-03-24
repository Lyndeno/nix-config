{
  ls = folder: (builtins.attrNames (builtins.readDir folder));
}
