{
  tmp.useTmpfs = true;
  swraid.enable = false;

  initrd.systemd.enable = true;

  kernelParams = [
    "8250.nr_uarts=1"
    "console=ttyS0,115200"
    "console=tty1"
    "cma=128M"
  ];
}
