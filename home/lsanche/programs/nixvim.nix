{
  config,
  inputs,
  pkgs,
  osConfig,
  lib,
}:
lib.mkIf osConfig.modules.desktop.enable (let
  cmp-notmuch = pkgs.vimUtils.buildVimPlugin {
    name = "cmp-notmuch";
    src = inputs.cmp-notmuch;
  };
in {
  enable = true;
  viAlias = true;
  vimAlias = true;
  defaultEditor = true;
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
    clipboard = "unnamedplus";
    termguicolors = true;
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
  lsp = {
    inlayHints.enable = true;
    keymaps = [
      {
        key = "gd";
        lspBufAction = "definition";
      }
      {
        key = "gD";
        lspBufAction = "references";
      }
      {
        key = "gt";
        lspBufAction = "type_definition";
      }
      {
        key = "gi";
        lspBufAction = "implementation";
      }
      {
        key = "gra";
        action = config.lib.nixvim.mkRaw "require('actions-preview').code_actions";
      }
      {
        key = "K";
        #lspBufAction = "hover";
        #action = "vim.lsp.buf.hover()";
        action = config.lib.nixvim.mkRaw "function() vim.lsp.buf.hover() end";
      }
      {
        action = config.lib.nixvim.mkRaw "function() vim.diagnostic.jump({ count=-1, float=true }) end";
        key = "<leader>k";
      }
      {
        action = config.lib.nixvim.mkRaw "function() vim.diagnostic.jump({ count=1, float=true }) end";
        key = "<leader>j";
      }
      {
        action = "<CMD>LspStop<Enter>";
        key = "<leader>lx";
      }
      {
        action = "<CMD>LspStart<Enter>";
        key = "<leader>ls";
      }
      {
        action = "<CMD>LspRestart<Enter>";
        key = "<leader>lr";
      }
      #{
      #  action = config.lib.nixvim.mkRaw "require('telescope.builtin').lsp_definitions";
      #  key = "gd";
      #}
      #{
      #  action = "<CMD>Lspsaga hover_doc<Enter>";
      #  key = "K";
      #}
    ];
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
      #systemd_ls.enable = true;
      gopls.enable = true;
      neocmake.enable = true;
      just.enable = true;
      jsonls.enable = true;
    };
  };
  extraPlugins = [
    cmp-notmuch
  ];
  plugins = {
    otter.enable = true;
    lspconfig.enable = true;
    lsp-signature.enable = true;
    lspkind.enable = true;
    nix.enable = true;
    fugitive.enable = true;
    gitmessenger.enable = true;
    telescope = {
      enable = true;
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
          {
            name = "nvim_lsp";
            priority = 1000;
          }
          {
            name = "nvim_lsp_signature_help";
            priority = 1000;
          }
          {
            name = "nvim_lsp_document_symbol";
            priority = 1000;
          }
          {
            name = "luasnip";
            priority = 750;
          }
          {
            name = "render-markdown";
            priority = 750;
          }
          {
            name = "buffer";
            priority = 500;
          }
          {
            name = "rg";
            priority = 300;
          }
          {
            name = "async_path";
            priority = 300;
          }
          {
            name = "git";
            priority = 250;
          }
          {
            name = "nixpkgs_maintainers";
            priority = 250;
          }
          {
            name = "notmuch";
            priority = 250;
          }
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
        tools = {
          enable_clippy = true;
          hover_actions.replace_builtin_hover = true;
        };
        server.default_settings = {
          rust-analyzer = {
            cargo.allFeatures = true;
            check.command = "clippy";
            inlayHints = {
              lifetimeElisionHints = {
                enable = "always";
              };
            };
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
    actions-preview = {
      enable = true;
    };
    neotest = {
      #enable = true;
      settings.adapters = [
        "require('rustaceanvim.neotest')"
      ];
    };
  };
})
