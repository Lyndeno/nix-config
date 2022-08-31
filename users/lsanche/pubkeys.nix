{pkgs, ...}: rec {
  strings = {
    morpheus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEjPlzlPcny6ZKwNzdlzi85lrIhPtdjLDRov29Fbef60";
    neo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtYA9xm9hQtFt5r7WuED1kkmvfezCURg6Tx9Ch1q0Ie";
    oracle = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG8hU9yYrAg76q1zp6rfhOBxSjwSwzQFpJTdBynWSCKA";
    trinity = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIGB5Ui/De31w1o/Z6ce0gNt6LDC+1W1skbNtQrw4DE6";
  };
  files = builtins.mapAttrs (name: value: pkgs.writeText "lsanche-${name}.pub" ''
      ${value}
    '') strings;
}