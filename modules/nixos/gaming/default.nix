# meta.description = "Steam, Gamescope and gaming applications"
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gamescope
    (prismlauncher.override {jdks = [jdk25];})
    dolphin-emu
  ];

  hardware.steam-hardware.enable = true;

  programs.steam.enable = true;
}
