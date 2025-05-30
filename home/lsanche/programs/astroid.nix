{config}: {
  enable = true;
  pollScript = "${config.programs.mujmap.package}/bin/mujmap -C ~/Maildir/fastmail sync";
  externalEditor = "${config.programs.alacritty.package}/bin/alacritty --class hover -e ${config.programs.nixvim.build.package}/bin/nvim -c 'set ft=mail' '+set fileencoding=utf-8' '+set ff=unix' '+set enc=utf-8' '+set fo+=w' %1";
}
