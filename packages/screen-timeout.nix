{
  pkgs,
  pname,
}:
# Power off all monitors via niri (used as a swayidle timeout / lock helper).
pkgs.writeShellApplication {
  name = pname;

  runtimeInputs = [pkgs.niri];

  text = ''
    niri msg action power-off-monitors
  '';

  meta.description = "Powers off all monitors via niri";
  meta.platforms = pkgs.lib.platforms.linux;
}
