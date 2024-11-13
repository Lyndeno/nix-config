{
  lib,
  pkgs,
  osConfig,
}: {
  inherit (osConfig.mods.desktop) enable;
  configFile."autostart/gnome-keyring-ssh.desktop" = lib.mkIf osConfig.mods.desktop.enable {
    text = ''
      ${lib.fileContents "${pkgs.gnome-keyring}/etc/xdg/autostart/gnome-keyring-ssh.desktop"}
      Hidden=true
    '';
  };
}
