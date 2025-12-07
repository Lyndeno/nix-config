{
  pkgs,
  pname,
}:
pkgs.writeShellApplication {
  name = pname;

  runtimeInputs = with pkgs; [
    acpi
    coreutils
  ];

  text = ''
    acpi -a | cut -d" " -f3 | cut -d- -f1
  '';
}
