{osConfig}: {
  inherit (osConfig.modules.desktop) enable;
  settings = {
    cpu_stats = true;
    gpu_stats = true;
    cpu_mhz = true;
    cpu_temp = true;
    gpu_temp = true;
    vulkan_driver = true;
    ram = true;
    vram = true;
    position = "bottom-left";
    frame_timing = false;
    cpu_power = true;
    gpu_power = true;
    arch = true;
  };
}
