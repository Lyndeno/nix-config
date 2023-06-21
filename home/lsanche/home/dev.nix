{pkgs, ...}: {
  home.packages = with pkgs; [nil clang-tools bear lldb clippy rustfmt];
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      matklad.rust-analyzer
      pkief.material-icon-theme
      usernamehw.errorlens
      yzhang.markdown-all-in-one
      ibm.output-colorizer
      christian-kohler.path-intellisense
      mechatroner.rainbow-csv
      jnoortheen.nix-ide
      eamodio.gitlens
      llvm-vs-code-extensions.vscode-clangd
      mkhl.direnv
      vadimcn.vscode-lldb
    ];
    userSettings = {
      git = {
        autofetch = true;
        confirmSync = false;
        enableSmartCommit = true;
      };
      window = {
        menuBarVisibility = "toggle";
        titleBarStyle = "native";
      };
      diffEditor.renderSideBySide = true;
      workbench = {
        iconTheme = "material-icon-theme";
        editor = {
          decorations.badges = true;
          decorations.colors = true;
          wrapTabs = true;
        };
      };
      editor = {
        cursorSmoothCaretAnimation = "on";
        smoothScrolling = true;
        cursorBlinking = "phase";
        fontLigatures = true;
        guides.bracketPairs = true;
      };
      nix = {
        enableLanguageServer = true;
        serverPath = "nil";
        serverSettings = {
          nil = {
            formatting = {
              command = ["nix" "fmt" "--" "--quiet" "-"];
            };
          };
        };
      };
      rust-analyzer.checkOnSave.command = "clippy";
    };
  };
}
