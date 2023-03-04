{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home-manager.users.lsanche.home.packages = with pkgs; [nil clang-tools bear];
  home-manager.users.lsanche.programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
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
    ];
    mutableExtensionsDir = true;
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
        cursorSmoothCaretAnimation = true;
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
      "[nix]" = {
        editor.formatOnSave = true;
      };
      update.mode = "none";
    };
  };
}
