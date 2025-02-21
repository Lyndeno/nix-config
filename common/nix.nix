{inputs}: {
  settings = {
    auto-optimise-store = true;
    trusted-users = [
      "root"
      "@wheel"
    ];
  };
  extraOptions = ''
    experimental-features = nix-command flakes
    keep-outputs = true
    keep-derivations = true
    always-allow-substitutes = true
  '';
  gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };
  registry.nixpkgs.flake = inputs.nixpkgs;
  nixPath = ["nixpkgs=${inputs.nixpkgs}"];
}
