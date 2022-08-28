{ config, pkgs, lib, inputs, ... }:
let
    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions/extensions.lock).extensions;
in
{
    home-manager.users.lsanche.programs.vscode = {
      enable = true;
      package = (pkgs.symlinkJoin {
        name = "vscode";
        pname = "vscode";
        #paths = [ (pkgs.vscode-with-extensions.override {
        #  vscodeExtensions = extensions;
        #})];
        paths = [ pkgs.vscode ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
            wrapProgram $out/bin/code \
            --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
        '';
      });
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
      ] ++ extensions;
      mutableExtensionsDir = false;
      userSettings = {
        "editor.cursorSmoothCaretAnimation" = true;
        "editor.smoothScrolling" = true;
        "editor.cursorBlinking" = "phase";
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;
        "workbench.iconTheme" = "material-icon-theme";
        "editor.fontLigatures" = true;
        "editor.fontFamily" = "'CaskaydiaCove Nerd Font'";
        "terminal.integrated.fontFamily" = "'CaskaydiaCove Nerd Font'";
        "window.menuBarVisibility" = "toggle";
        "window.titleBarStyle" = "custom";
        "workbench.editor.decorations.badges" = true;
        "workbench.editor.decorations.colors" = true;
        "workbench.editor.wrapTabs" = true;
        "diffEditor.renderSideBySide" = true;
        "editor.guides.bracketPairs" = true;
      };
    };
}
