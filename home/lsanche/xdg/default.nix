{
  lib,
  osConfig,
}: {
  inherit (osConfig.mods.desktop) enable;
  configFile."autostart/gnome-keyring-ssh.desktop" = lib.mkIf osConfig.mods.desktop.enable {
    text = ''
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
