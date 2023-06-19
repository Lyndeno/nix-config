{inputs}: {
  _imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  enable = true;
  pkiBundle = "/etc/secureboot";
  settings = {
    console-mode = "max";
    timeout = 0;
  };
}
