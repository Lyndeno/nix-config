{
  pkgs,
  isDesktop,
  inputs,
}: {
  enable = isDesktop;
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
    dart-code.dart-code
    dart-code.flutter
    github.vscode-pull-request-github
    github.vscode-github-actions
    redhat.vscode-xml
    graphql.vscode-graphql
    graphql.vscode-graphql-syntax
    tamasfe.even-better-toml
    inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace.bodil.blueprint-gtk
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
      #autoDetectColorScheme = true;
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
          maxMemoryMB = null;
          formatting = {
            command = ["nix" "fmt" "--" "--quiet" "-"];
          };
          flake = {
            autoArchive = true;
            autoEvalInputs = true;
          };
        };
      };
    };
    rust-analyzer.checkOnSave.command = "clippy";
  };
}
