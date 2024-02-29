{}: {
  enable = true;
  #configFile."autostart/gnome-keyring-ssh.desktop".text = ''
  #  ${lib.fileContents "${pkgs.gnome.gnome-keyring}/etc/xdg/autostart/gnome-keyring-ssh.desktop"}
  #  Hidden=true
  #'';
}
