# meta.description = "Neovim configured via nixvim (LSP, completion, plugins)"
{inputs, ...}: {
  pkgs,
  config,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./lsp.nix
    ./completion.nix
    ./plugins.nix
  ];

  stylix.targets.nixvim.transparentBackground = {
    main = true;
    signColumn = true;
  };

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    highlight.LspInlayHint.link = "Comment";
    highlightOverride = {
      NormalNC = {
        bg = "none";
        ctermbg = "none";
      };
      WinSeparator = {
        bg = "none";
        fg = "none";
      };
      LineNr.link = "Comment";
      LineNrAbove.link = "Comment";
      LineNrBelow.link = "Comment";
    };
    nixpkgs = {
      inherit pkgs;
    };
    performance = {
      byteCompileLua = {
        enable = true;
        configs = true;
        initLua = true;
        luaLib = true;
        nvimRuntime = true;
        plugins = true;
      };
    };
    autoCmd = [
      {
        # vim-floaterm's plugin/floaterm.vim links Floaterm/FloatermNC/FloatermBorder
        # to Normal/NormalNC/NormalFloat with `hi default link`, which runs during
        # plugin loading and clobbers a highlightOverride set earlier in init.lua.
        # Reapply on FileType instead, since that only fires once the plugin (and
        # its default links) are already loaded.
        callback = config.lib.nixvim.mkRaw ''
          function()
            local floatermHighlights = {
              Floaterm = {bg = "none", ctermbg = "none"},
              FloatermNC = {bg = "none", ctermbg = "none"},
              FloatermBorder = {bg = "none", ctermbg = "none"},
            }
            for name, val in pairs(floatermHighlights) do
              vim.api.nvim_set_hl(0, name, val)
            end
          end
        '';
        pattern = ["floaterm"];
        event = ["FileType"];
      }
      {
        #command = "setlocal textwidth=80";
        callback = config.lib.nixvim.mkRaw ''
          function()
            vim.opt_local.textwidth = 80
            vim.opt_local.spell = true
            vim.opt_local.spelllang = {"en_ca"}
          end
        '';
        pattern = [
          "*.md"
          "*.typ"
          "*.txt"
        ];
        event = [
          "BufEnter"
          "BufRead"
          "BufNewFile"
        ];
      }
    ];
    opts = {
      number = true;
      signcolumn = "yes:1";
      relativenumber = true;
      cmdheight = 0;
      hlsearch = true;
      incsearch = true;
      showmode = false;
      showcmd = false;
      tabstop = 2;
      ignorecase = true;
      smartcase = true;
      undofile = true;
      scrolloff = 8;
      clipboard = "unnamedplus";
      termguicolors = true;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      linebreak = true;
      breakindent = true;
      showbreak = "↪ ";
      fillchars = {vert = "│";};
    };
    diagnostic.settings = {
      virtual_text = true;
      virtual_lines.current_line = true;
    };
    filetype = {
      pattern = {
        "%.gitlab%-ci%.ya?ml" = "yaml.gitlab";
      };
    };
    keymaps = [
      {
        key = "j";
        action = "gj";
        mode = ["n" "v"];
      }
      {
        key = "k";
        action = "gk";
        mode = ["n" "v"];
      }
    ];
  };
}
