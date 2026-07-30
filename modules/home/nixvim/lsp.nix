{config, ...}: {
  programs.nixvim.lsp = {
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
      fish_lsp.enable = true;
      bashls.enable = true;
      gitlab_ci_ls.enable = true;
      ruff.enable = true;
      systemd_lsp.enable = true;
      gopls.enable = true;
      neocmake.enable = true;
      just.enable = true;
      jsonls.enable = true;
      perlnavigator.enable = true;
      tinymist.enable = true;
    };
  };
}
