{
  pkgs,
  pname,
}:
# Show the weather in a terminal and wait for a keypress (waybar on-click).
pkgs.writeShellApplication {
  name = pname;

  runtimeInputs = [pkgs.curl];

  text = ''
    curl https://wttr.in
    read -r -p "Press Any Key to Continue"
  '';

  meta.platforms = pkgs.lib.platforms.linux;
}
