{pkgs, ...}: {
  boot.initrd.availableKernelModules = ["nvme" "mpt3sas" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelModules = ["kvm-amd" "jc42" "nct6775"];
  boot.extraModulePackages = [];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  services.xserver.videoDrivers = ["amdgpu"];
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
}
