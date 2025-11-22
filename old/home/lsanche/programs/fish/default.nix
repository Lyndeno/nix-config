{
  enable = true;
  interactiveShellInit = ''
    set -g fish_greeting
  '';
  binds = {
    "ctrl-space".command = "accept-autosuggestion";
  };
  shellAbbrs = {
    gpf = "git push --force-with-lease";
    gca = "git commit --amend";
    gp = "git push";
  };
}
