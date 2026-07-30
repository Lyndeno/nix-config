{
  pkgs,
  perSystem,
  pname,
  ...
}:
# Power off monitors on idle, but only while the screen is locked.
pkgs.writeShellApplication {
  name = pname;

  runtimeInputs = [
    pkgs.procps
    perSystem.self.screen-timeout
  ];

  text = ''
    if pgrep swaylock
    then
      screen-timeout
    fi
  '';

  meta.platforms = pkgs.lib.platforms.linux;
}
