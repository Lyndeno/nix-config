{
  pkgs,
  inputs,
  pname,
  ...
}:
pkgs.vimUtils.buildVimPlugin {
  name = pname;
  src = inputs.cmp-notmuch;
}
