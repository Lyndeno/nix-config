{
  enable = true;
  viAlias = true;
  vimAlias = true;
  defaultEditor = true;
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
  plugins = {
    nix.enable = true;
    fugitive.enable = true;
    lsp = {
      enable = true;
      inlayHints = true;
      servers = {
        nixd.enable = true;
        clangd.enable = true;
        texlab.enable = true;
        blueprint_ls.enable = true;
        dockerls.enable = true;
        fish_lsp.enable = true;
        bashls.enable = true;
        gitlab_ci_ls.enable = true;
        ruff.enable = true;
        systemd_ls.enable = true;
        gopls.enable = true;
        neocmake.enable = true;
        just.enable = true;
        jsonls.enable = true;
      };
    };
    treesitter = {
      enable = true;
      settings = {
        highlight = {
          enable = true;
        };
      };
    };
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [
          {name = "nvim_lsp";}
          {name = "luasnip";}
          {name = "render-markdown";}
        ];
        mapping = {
          "<C-u>" = "cmp.mapping.scroll_docs(-4)";
          "<C-d>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<CR>" = ''
            cmp.mapping.confirm {
              behavior = cmp.ConfirmBehavior.Insert,
              select = true,
            }
          '';
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<C-j>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<C-k>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        };
      };
    };
    luasnip.enable = true;
    lualine = {
      enable = true;
      settings = {
        sections = {
          lualine_c = [
            "filename"
          ];
        };
        extensions = [
          "neo-tree"
        ];
      };
    };
    gitgutter = {
      enable = true;
    };
    floaterm = {
      enable = true;
      settings = {
        keymap_toggle = "<Leader>t";
        width = 0.8;
        height = 0.8;
      };
    };
    neo-tree = {
      enable = true;
    };
    markdown-preview = {
      enable = true;
    };
    nvim-autopairs = {
      enable = true;
      settings.check_ts = true;
    };
    mini = {
      enable = true;
      mockDevIcons = true;
      modules.icons.enable = true;
    };
    rustaceanvim = {
      enable = true;
      settings = {
        enable_clippy = true;
        inlayHints = {
          lifetimeElisionHints = {
            enable = "always";
          };
        };
      };
    };
    fidget = {
      enable = true;
    };
    dap = {
      enable = true;
    };
    gitblame = {
      enable = true;
    };
    render-markdown = {
      enable = true;
    };
    git-conflict = {
      enable = true;
    };
  };
}
