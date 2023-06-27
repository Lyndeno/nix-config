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
  settings.substituters = [
    "https://nix-community.cachix.org"
  ];
  settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
}
