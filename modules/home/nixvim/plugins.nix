{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = [
      pkgs.vim-niri-nav
    ];
    plugins = {
      claude-code.enable = true;
      otter.enable = true;
      lspconfig.enable = true;
      nix.enable = true;
      fugitive.enable = true;
      gitmessenger.enable = true;
      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
        };
      };
      treesitter = {
        enable = true;
        highlight = {
          enable = true;
        };
      };
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
        settings = {
          close_if_last_window = true;
          filesystem = {
            follow_current_file = {
              enabled = true;
              leave_dirs_open = true;
            };
          };
        };
      };
      #markdown-preview = {
      #  enable = true;
      #};
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
      which-key.enable = true;
      guess-indent.enable = true;
      hmts = {
        enable = true;
        package = pkgs.hmts;
      };
      illuminate.enable = true;
      lensline.enable = true;
      neogit.enable = true;
      nerdy = {
        enable = true;
        enableTelescope = true;
      };
      numbertoggle.enable = true;
      timerly.enable = true;
      twilight = {
        enable = true;
        settings.treesitter = true;
      };
      zen-mode = {
        enable = true;
        settings.plugins = {
          options = {
            enabled = true;
            ruler = false;
            showcmd = false;
            number = false;
            relativenumber = false;
            signcolumn = "no";
          };
          alacritty = {
            enabled = true;
            font = "14";
          };
        };
      };
      neotest = {
        enable = true;
        settings.adapters = [
          "require('rustaceanvim.neotest')"
        ];
      };
      rainbow-delimiters.enable = true;
      #indent-blankline = {
      #  enable = true;
      #};
    };
  };
}
