{pkgs}: {
  libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  docker.enable = true;
}
