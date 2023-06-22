{pkgs}: {
  # Enable CUPS to print documents.
  printing.enable = true;
  printing.drivers = [pkgs.gutenprint pkgs.cups-bjnp];
}
