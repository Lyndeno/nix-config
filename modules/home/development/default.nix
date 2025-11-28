{
  config,
  pkgs,
  ...
}: {
  home = {
    file = {
      ".cargo/config.toml" = {
        text =
          # toml
          ''
            [build]
            target-dir = "${config.home.homeDirectory}/.cargo/target"
          '';
      };
    };
    packages = with pkgs; [
      nixd
      rust-analyzer
      texlab
      clang-tools
      bear
      lldb
      clippy
      rustfmt
      nix-output-monitor
      nixpkgs-review
    ];
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };
  };
}
