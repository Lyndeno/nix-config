{
  enable = true;
  interactiveShellInit = ''
    set -g fish_greeting
    bind -k nul accept-autosuggestion
  '';
}
