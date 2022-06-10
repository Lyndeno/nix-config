{ config, pkgs, lib, ... }:

let
  commands = {
    lock = "${pkgs.swaylock-effects}/bin/swaylock";
  };
in
{
  imports = [ ./modules/desktop.nix 
    ./modules/avizo.nix
  ];
  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "lsanche";
    homeDirectory = "/home/lsanche";
    enableNixpkgsReleaseCheck = true;

    packages = with pkgs; [
      # Fonts
      #neofetch
      #jq
      neofetch
    ];
  };

  programs = {
    bottom.enable = true;
    bat.enable = true;
    exa.enable = true;
    fzf.enable = true;
    vim = {
      enable = true;
      settings = {
        tabstop = 2;
      };
      plugins = with pkgs.vimPlugins; [
        jellybeans-vim
        lightline-vim
        fugitive
      ];
      extraConfig = ''
        syntax on
        set number
        set noswapfile
        set hlsearch
        set ignorecase
        set incsearch
        set noshowmode
        set encoding=utf-8
        set hidden
        set nobackup
        set nowritebackup
        set cmdheight=1
        set shiftwidth=0
        set t_Co=256
        colorscheme jellybeans

        hi Normal guibg=NONE ctermbg=NONE
        hi NonText guibg=NONE ctermbg=NONE
        hi CursorLineNr guibg=NONE ctermbg=NONE
        hi LineNr guibg=NONE ctermbg=NONE
        hi Todo cterm=none ctermfg=white ctermbg=red

        let g:lightline = {
          \ 'active': {
          \   'left': [ [ 'mode', 'paste' ],
          \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
          \ },
          \ 'component_function': {
          \   'gitbranch': 'FugitiveHead'
          \ },
          \ }

        set signcolumn=number
        set relativenumber
    '';
    };

    nnn = {
      enable = true;
      package = pkgs.nnn.override ({withNerdIcons = true; });
      plugins.src = (config.programs.nnn.package.src) + "/plugins";
    };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true; # seems this is a new addition
      history = {
        path = "$HOME/.cache/zsh/histfile";
      };
      shellAliases = {
        cat = "${pkgs.bat}/bin/bat";
        ls = "${pkgs.exa}/bin/exa --icons --group-directories-first -B";
      };
      initExtra = ''
        zmodload zsh/complist
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' menu select

        # Vim bindings for tab menu
        bindkey -M menuselect 'h' vi-backward-char
        bindkey -M menuselect 'k' vi-up-line-or-history
        bindkey -M menuselect 'l' vi-forward-char
        bindkey -M menuselect 'j' vi-down-line-or-history

        setopt AUTO_PUSHD
        setopt PUSHD_IGNORE_DUPS
        setopt PUSHD_SILENT
        # TODO: Convert this to nix expressions
        alias d='dirs -v'
        for i ({1..9}) alias "$i"="cd +''${i}"; unset i

        source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
        ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
        typeset -A ZSH_HIGHLIGHT_PATTERNS
        ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
        bindkey '^ ' autosuggest-accept
        bindkey "$terminfo[kcuu1]" history-substring-search-up
        bindkey "$terminfo[kcud1]" history-substring-search-down
      '';
    };
    git = {
      enable = true;
      userName = "Lyndon Sanche";
      userEmail = "lsanche@lyndeno.ca";
      signing.key = "6F8E82F60C799B18";
      signing.signByDefault = true;
      extraConfig = {
        pull.rebase = false;
      };
    };
    ssh = {
      enable = true;
    };
    #vscode = {
    #  enable = true;
    #  #package = (pkgs.symlinkJoin {
    #  #        name = "vscode";
    #  #        pname = "vscode";
    #  #        paths = [ pkgs.vscode ];
    #  #        buildInputs = [ pkgs.makeWrapper ];
    #  #        postBuild = ''
    #  #            wrapProgram $out/bin/code \
    #  #            --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
    #  #        '';
    #  #    });
    #  extensions = (with pkgs.vscode-extensions; [
    #    vscodevim.vim
    #    ms-vscode.cpptools
    #    usernamehw.errorlens
    #    yzhang.markdown-all-in-one
    #    pkief.material-icon-theme
    #    ibm.output-colorizer
    #    #christian-kohler.path-intellisense
    #    mechatroner.rainbow-csv
    #    #rust-lang.rust
    #    #wayou.vscode-todo-highlight
    #    jnoortheen.nix-ide
    #    matklad.rust-analyzer
    #    arrterian.nix-env-selector
    #  ]);
    #  userSettings = {
    #    "editor.cursorSmoothCaretAnimation" = true;
    #    "editor.smoothScrolling" = true;
    #    "editor.cursorBlinking" = "phase";
    #    "git.autofetch" = true;
    #    "git.confirmSync" = false;
    #    "git.enableSmartCommit" = true;
    #    "workbench.iconTheme" = "material-icon-theme";
    #    "editor.fontLigatures" = true;
    #    "editor.fontFamily" = "'CaskaydiaCove Nerd Font'";
    #    "terminal.integrated.fontFamily" = "'CaskaydiaCove Nerd Font'";
    #    "window.menuBarVisibility" = "toggle";
    #    "workbench.editor.decorations.badges" = true;
    #    "workbench.editor.decorations.colors" = true;
    #    "workbench.editor.wrapTabs" = true;
    #    "diffEditor.renderSideBySide" = true;
    #  };
    #};

    starship = {
      enable = true;
      settings = {
        add_newline = false;

        format = lib.concatStrings [
          "$username$hostname$directory\n"
          "$battery"
          "$jobs"
          "$memory_usage"
          "$git_branch"
          "$git_status"
          "$rust"
          "$cmake"
          "$cmd_duration"
          "$nix_shell"
          "$character"
        ];

        cmd_duration = {
          min_time = 10000;
          format = "[$duration]($style) ";
          show_notifications = true;
        #cmd_duration.notification_timeout = 3000;
        };

        cmake = {
          format = "[$symbol]($version)]($style) ";
          style = "bold cyan";
        };

        hostname.format = "@[$hostname](bold yellow):";

        directory = {
          truncation_symbol = ".../";
          truncation_length = 5;
        };

        memory_usage = {
          disabled = true;
          threshold = 50;
        };

        git_branch.format = "[$symbol$branch]($style) ";

        jobs.symbol = " ";

        username = {
          format = "[$user]($style)";
          style_user = "bold green";
        };
      };
    };
  };

  xdg = {
    enable = true;
    userDirs.enable = true;
    userDirs.createDirectories = false;
  };

  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "firefox";
    MANPAGER="sh -c '${pkgs.util-linux}/bin/col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  };

  #fonts.fontconfig.enable = true;

  # TODO: This module will be in next hm release
  #services.swayidle = {
  #  enable = true;
  #  events = [
  #    { event = "before-sleep"; command = "${pkgs.swaylock-effects}/bin/swaylock"; }
  #  ];
  #  timeouts = [
  #    { timeout = 30; command = "if pgrep swaylock; then swaymsg 'output * dpms off'"; }
  #  ];
  #};

  #programs.firefox = {
  #  enable = true;
  #  package = pkgs.firefox-wayland;
  #};

  #services.gpg-agent = {
  #  enable = true;
  #  #enableSshSupport = true;
  #  pinentryFlavor = "gnome3";
  #};
  #services.gnome-keyring = {
  #  enable = true;
  #  components = [ "secrets" "ssh" ];
  #};

  nixpkgs.config.allowUnfree = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  #home.stateVersion = "21.11";
}
