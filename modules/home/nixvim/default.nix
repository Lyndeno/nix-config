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
      # `stylix.targets.nixvim.transparentBackground` also sets Normal/NormalNC's
      # bg here, via nvim_set_hl (a full replace, not a `:highlight`-style merge).
      # Without an explicit fg, that wipes out the fg mini.base16 set moments
      # earlier, leaving Normal (and derivatives, e.g. neo-tree's popup title
      # bar) with no foreground at all: it falls back to the terminal's raw
      # default fg, which can land on an equally light background and render
      # invisible (e.g. the neo-tree "add file" prompt title).
      Normal.fg = config.lib.stylix.colors.withHashtag.base05;
      NormalNC = {
        fg = config.lib.stylix.colors.withHashtag.base05;
        bg = "none";
        ctermbg = "none";
      };
      # neo-tree's "NC" popup border style (used for its rename/add/filter
      # prompts) derives its title-bar text color from Normal's *background*,
      # inverted, on the assumption it's a real opaque color — but we make it
      # transparent above, so that derivation yields no color at all and the
      # title falls back to the same invisible-on-invisible look. Setting both
      # fg and bg here directly (rather than leaving one to be derived) makes
      # neo-tree's own highlight setup see an already-complete group and skip
      # recomputing it.
      NeoTreeTitleBar = {
        fg = config.lib.stylix.colors.withHashtag.base00;
        bg = config.lib.stylix.colors.withHashtag.base05;
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
