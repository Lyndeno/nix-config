{inputs, ...}: {
  imports = with inputs.nixos-hardware.nixosModules; [
    common-gpu-amd
    common-cpu-amd
    common-cpu-amd-pstate
    common-pc-ssd
  ];

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
  };

  boot = {
    kernelModules = ["kvm-amd" "jc42" "nct6775" "ddcci" "sg"];
    initrd = {
      availableKernelModules = ["nvme" "mpt3sas" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
    };
  };
}
