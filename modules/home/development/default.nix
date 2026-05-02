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
      caligula
      nix-fast-build
    ];
  };

  programs = {
    claude-code.enable = true;
    opencode = {
      enable = true;
      settings = {
        provider = {
          laptop = {
            name = "Morpheus";
            npm = "@ai-sdk/openai-compatible";
            options = {
              baseURL = "https://ollama.lyndeno.ca/v1";
              apiKey = "none";
            };
            models = {
              "qwen3.5:2b" = {
                name = "qwen3.5:2b";
                tool_call = true;
                temperature = true;
                limit = {
                  context = 256000;
                  output = 16384;
                };
              };
            };
          };
        };
      };
    };
    git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        pull.rebase = false;
      };
      ignores = [
        "result"
        "result-*"
        ".direnv/"
        ".envrc"
        ".vscode/"
        ".claude/"
      ];
    };
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
