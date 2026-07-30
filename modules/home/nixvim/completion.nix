{
  # Completion engine, snippets and related UI.
  programs.nixvim.plugins = {
    lsp-signature.enable = true;
    lspkind.enable = true;
    luasnip.enable = true;
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
        ];
        mapping = {
          "<C-u>" = "cmp.mapping.scroll_docs(-4)";
          "<C-d>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<CR>" = ''
            cmp.mapping.confirm {
              behavior = cmp.ConfirmBehavior.Insert,
              select = false,
            }
          '';
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<C-j>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<C-k>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        };
      };
    };
  };
}
