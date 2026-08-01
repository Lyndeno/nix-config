# meta.description = "Spotify desktop client"
{inputs, ...}: {
  imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify
  ];
  programs.spicetify.enable = true;
}
