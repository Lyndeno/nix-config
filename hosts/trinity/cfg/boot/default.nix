{pkgs}: {
  kernelPackages = pkgs.linuxPackages_rpi4; # Raspberry pies have a hard time booting on the LTS kernel.

  tmp.useTmpfs = true;

  kernelParams = [
    "8250.nr_uarts=1"
    "console=ttyS0,115200"
    "console=tty1"
    "cma=128M"
  ];
}
