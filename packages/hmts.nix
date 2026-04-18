{pkgs, ...}:
pkgs.vimUtils.buildVimPlugin {
  pname = "hmts.nvim";
  version = "2025-06-11";
  src = pkgs.fetchFromGitHub {
    owner = "charliie-dev";
    repo = "hmts.nvim";
    rev = "15afe9503a2884395f00d88ea697c88aadee8619";
    sha256 = "sha256-7Wnb0UxhSwWxPgabmlQlc8JlDD4alF0PBlhM9oM7pTc=";
  };
  meta.homepage = "https://github.com/calops/hmts.nvim/";
  meta.hydraPlatforms = [];
}
