{
  config,
  pkgs,
  lib,
  isDesktop,
  ...
}: {
  home.packages = with pkgs; lib.mkIf isDesktop [nil clang-tools bear lldb clippy rustfmt];
  programs.vscode = lib.mkIf isDesktop {
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
      terminal.integrated.fontFamily = "'${config.stylix.fonts.monospace.name}'";
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
        fontFamily = "'${config.stylix.fonts.monospace.name}'";
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