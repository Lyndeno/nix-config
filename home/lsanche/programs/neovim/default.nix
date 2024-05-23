{
  pkgs,
  lib,
  config,
  inputs,
}: {
  enable = true;
  defaultEditor = true;

  vimAlias = true;
  vimdiffAlias = true;

  plugins = with pkgs.vimPlugins; [
    vim-nix
    fugitive
    (lightline-vim.overrideAttrs (
      _old: let
        schemeFile = config.lib.stylix.colors inputs.base16-vim-lightline;
      in {patchPhase = ''cp ${schemeFile} autoload/lightline/colorscheme/base16_${config.lib.stylix.colors.scheme-slug-underscored}.vim'';}
    ))
    nvim-lspconfig
    nvim-treesitter.withAllGrammars
  ];
  extraLuaConfig =
    # lua
    ''
      require'lspconfig'.rust_analyzer.setup{}
      require'lspconfig'.nixd.setup{}
      require'lspconfig'.clangd.setup{}
      require'lspconfig'.texlab.setup{}

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
      let g:lightline = {
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ],
        \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
        \ },
        \ 'component_function': {
        \   'gitbranch': 'FugitiveHead'
        \ },
        \ }

      let g:lightline.colorscheme = 'base16_${config.lib.stylix.colors.scheme-slug-underscored}'

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
