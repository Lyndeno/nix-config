{
  settings.auto-optimise-store = true;
  extraOptions = ''
    experimental-features = nix-command flakes
    keep-outputs = true
    keep-derivations = true
  '';
  gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };
}
