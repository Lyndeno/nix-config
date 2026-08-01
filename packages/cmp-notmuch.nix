{
  pkgs,
  inputs,
  pname,
  ...
}:
pkgs.vimUtils.buildVimPlugin {
  name = pname;
  src = inputs.cmp-notmuch;
  meta.description = "nvim-cmp completion source backed by notmuch";
}
