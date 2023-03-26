{
  pkgs,
  username,
  ...
}: {
  isNormalUser = true;
  description = "Brandt Sanche";
  home = "/home/${username}";
  group = "${username}";
  extraGroups = [
    "wheel"
  ];
  shell = pkgs.zsh;
}
