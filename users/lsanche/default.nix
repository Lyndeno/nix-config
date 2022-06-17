{ config, lib, pkgs, inputs, ...}:
let
  myUsername = "lsanche";
in
{
  users.users."${myUsername}" = {
    isNormalUser = true;
    description = "Lyndon Sanche";
    home = "/home/${myUsername}";
    group = "${myUsername}";
    uid = 1000;
    extraGroups = [
      "wheel"
      "media"
      (lib.mkIf config.networking.networkmanager.enable "networkmanager") # Do not add this group if networkmanager is not enabled
    ];
    openssh.authorizedKeys.keys = [
      (lib.mkIf (config.networking.hostName == "morpheus") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEjPlzlPcny6ZKwNzdlzi85lrIhPtdjLDRov29Fbef60" )
      (lib.mkIf (config.networking.hostName == "neo") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtYA9xm9hQtFt5r7WuED1kkmvfezCURg6Tx9Ch1q0Ie" )
      (lib.mkIf (config.networking.hostName == "oracle") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG8hU9yYrAg76q1zp6rfhOBxSjwSwzQFpJTdBynWSCKA" )
    ];
    shell = pkgs.zsh;
  };
  users.groups = {
    "${myUsername}" = {};
  };
  home-manager.users."${myUsername}" = { pkgs, ... }:
  let
    hostConfig = ./home-manager/hosts + "/${config.networking.hostName}";
  in
  {
    imports = [
      ./home-manager/home.nix
      hostConfig
    ];
    home.stateVersion = config.system.stateVersion;
    programs.vim = {
      enable = true;
      settings = {
        tabstop = 2;
      };
      plugins = with pkgs.vimPlugins; [
        #jellybeans-vim
        fugitive
        (base16-vim.overrideAttrs (old:
          let schemeFile = config.scheme inputs.base16-vim;
          in { patchPhase = ''cp ${schemeFile} colors/base16-scheme.vim''; }
        ))
        (lightline-vim.overrideAttrs (old:
        let schemeFile = config.scheme inputs.base16-vim-lightline; 
        in { patchPhase = ''cp ${schemeFile} autoload/lightline/colorscheme/base16_.vim''; }
        ))
      ];
        #colorscheme jellybeans
      extraConfig =  ''
        set number
        set noswapfile
        set hlsearch
        set ignorecase
        set incsearch
        set noshowmode
        set encoding=utf-8
        set hidden
        set nobackup
        set nowritebackup
        set cmdheight=1
        set shiftwidth=0
        set t_Co=256


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
        colorscheme base16-scheme
        function! s:base16_customize() abort
          hi Normal guibg=NONE ctermbg=NONE
          hi NonText guibg=NONE ctermbg=NONE
          hi CursorLineNr guibg=NONE ctermbg=NONE
          hi LineNr guibg=NONE ctermbg=NONE
          hi Todo cterm=none ctermfg=white ctermbg=red
        endfunction

        augroup on_change_colorschema
          autocmd!
          autocmd ColorScheme * call s:base16_customize()
        augroup END
      '';
    };

  };
  }
