{
  pkgs,
  perSystem,
  pname,
  ...
}:
# Runs a system update, then holds the terminal open so the output stays
# visible after it finishes (used as a waybar on-click).
pkgs.writeShellApplication {
  name = pname;

  runtimeInputs = [perSystem.self.update-system];

  text = ''
    update-system switch || true
    read -n1 -rsp $'\nPress any key to close...\n'
  '';

  meta.platforms = pkgs.lib.platforms.linux;
}
