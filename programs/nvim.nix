{config, lib, pkgs, inputs, ...}:
{
    home-manager.users.lsanche.programs.neovim = {
      enable = true;

      vimAlias = true;
      vimdiffAlias = true;

      plugins = with pkgs.vimPlugins; [
        #jellybeans-vim
        vim-nix
        fugitive
        #(base16-vim.overrideAttrs (old:
        #  let schemeFile = config.scheme inputs.base16-vim;
        #  in { patchPhase = ''cp ${schemeFile} colors/base16-scheme.vim''; }
        #))
        (lightline-vim.overrideAttrs (old:
        let schemeFile = config.scheme inputs.base16-vim-lightline; 
        in { patchPhase = ''cp ${schemeFile} autoload/lightline/colorscheme/base16_.vim''; }
        ))
      ];
      extraConfig = ''
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
          \ 'colorscheme': 'base16_',
          \ }

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
    };
}
