{pkgs}: {
  enable = true;
  viAlias = true;
  vimAlias = true;
  opts = {
    number = true;
    signcolumn = "yes:1";
    relativenumber = true;
    cmdheight = 0;
    hlsearch = true;
    incsearch = true;
    showmode = false;
    showcmd = false;
  };
  extraPlugins = [
    pkgs.vimPlugins.lualine-lsp-progress
  ];
  plugins = {
    nix.enable = true;
    fugitive.enable = true;
    lsp = {
      enable = true;
      inlayHints = true;
      servers = {
        rust_analyzer = {
          enable = true;
          installRustc = false;
          installCargo = false;
        };
        nixd.enable = true;
        clangd.enable = true;
        texlab.enable = true;
      };
    };
    treesitter = {
      enable = true;
      settings = {
        highlight = {
          #additional_vim_regex_highlighting = true;
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
        ];
        mapping = {
          "<C-u>" = "cmp.mapping.scroll_docs(-4)";
          "<C-d>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<CR>" = ''
            cmp.mapping.confirm {
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            }
          '';
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
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
            "lsp_progress"
          ];
        };
      };
    };
    gitgutter = {
      enable = true;
    };
  };
}
