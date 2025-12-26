{
  pkgs,
  perSystem,
  pname,
  ...
}:
pkgs.writeShellApplication {
  name = pname;

  runtimeInputs = with pkgs; [
    systemd
    perSystem.self.battery-status
  ];

  text = ''
    BAT_STATUS=$(battery-status)
    if [ "$BAT_STATUS" = "off" ]
    then
      systemctl suspend-then-hibernate
    fi
  '';

  meta.platforms = pkgs.lib.platforms.linux;
}
