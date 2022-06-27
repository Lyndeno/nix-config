{pkgs, thm, ...}:
# Inspired from https://github.com/SenchoPens/senixos/blob/master/profiles/sway/default.nix
pkgs.writeText "swaylock-config" ''
  indicator-thickness=8
  daemonize
  color=${thm.base00}
  key-hl-color=${thm.green}
  separator-color=00000000
  inside-color=${thm.base00}
  inside-clear-color=${thm.base00}
  inside-ver-color=${thm.blue}
  inside-wrong-color=${thm.red}


  ring-color=${thm.base01}
  ring-clear-color=${thm.base01}
  inside-ver-color=${thm.blue}
  inside-wrong-color=${thm.red}
  ring-color=${thm.base01}
  ring-clear-color=${thm.base01}
  ring-ver-color=${thm.blue}
  ring-wrong-color=${thm.red}
  line-color=00000000
  line-clear-color=00000000
  line-ver-color=00000000
  line-wrong-color=00000000
  text-clear-color=${thm.orange}
  text-caps-lock-color=${thm.orange}
  text-ver-color=${thm.base00}
  text-wrong-color=${thm.base00}
  bs-hl-color=${thm.red}
''
