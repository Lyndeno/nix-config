{
  lib,
  osConfig,
}: {
  inherit (osConfig.modules.desktop) enable;
  configFile."autostart/gnome-keyring-ssh.desktop" = lib.mkIf osConfig.modules.desktop.enable {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=SSH Key Agent
      Comment=GNOME Keyring: SSH Agent
      Exec=/run/wrappers/bin/gnome-keyring-daemon --start --components=ssh
      OnlyShowIn=GNOME;Unity;MATE;
      X-GNOME-Autostart-Phase=PreDisplayServer
      X-GNOME-AutoRestart=false
      X-GNOME-Autostart-Notify=true
      Hidden=true
    '';
  };
}
