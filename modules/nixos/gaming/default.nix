{pkgs}: {
  environment.systemPackages = with pkgs; [
    gamescope
    prismlauncher
    dolphin-emu
  ];

  hardware.steam-hardware.enable = true;

  programs.steam.enable = true;
}
