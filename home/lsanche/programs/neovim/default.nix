{
  pkgs,
  lib,
}: {
  enable = true;
  defaultEditor = true;

  vimAlias = true;
  vimdiffAlias = true;

  plugins = with pkgs.vimPlugins; [
    vim-nix
    fugitive
    nvim-lspconfig
    nvim-treesitter.withAllGrammars
    nvim-cmp
    cmp-nvim-lsp
    cmp_luasnip
    luasnip
    lualine-nvim
  ];
  extraLuaConfig =
    # lua
    ''
      require('lualine').setup()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require('lspconfig')

      local servers = { 'clangd', 'rust_analyzer', 'nixd', 'texlab' }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          on_attach = function(client, bufnr)
            vim.lsp.inlay_hint.enable(true, {bufnr = bufnr})
          end,
          capabilities = capabilities,
          settings = {
            ['rust-analyzer'] = {
              check = {
                command = "clippy",
              },
            },
          },
        }
      end

      local luasnip = require 'luasnip'

      local cmp = require 'cmp'

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's', }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
      }

      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
        },
      }
    '';
  # mkAfter so we can override some stylix settings
  extraConfig =
    lib.mkAfter
    # vim
    ''
      set tabstop=2
      set noshowmode
      set hlsearch
      set ignorecase
      set incsearch
      set cmdheight=1
      set shiftwidth=0
      set noshowcmd " hide the keys pressed in normal mode

      set signcolumn=number
      set relativenumber

      " To make base16 look nice
      set termguicolors
      set background=dark
      let base16colorspace=256

      " To remove some of the highlights base16 introduces
      hi Normal guibg=NONE ctermbg=NONE
      hi NonText guibg=NONE ctermbg=NONE
      hi CursorLineNr guibg=NONE ctermbg=NONE
      hi LineNr guibg=NONE ctermbg=NONE
      hi Todo cterm=none ctermfg=white ctermbg=red

    '';
}
