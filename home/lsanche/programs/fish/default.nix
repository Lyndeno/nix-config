{
  enable = true;
  interactiveShellInit = ''
    set -g fish_greeting
  '';
  binds = {
    "ctrl-space".command = "accept-autosuggestion";
  };
}
