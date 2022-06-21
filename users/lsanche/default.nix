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

    programs.neovim = {
      enable = true;

      vimAlias = true;
      vimdiffAlias = true;

      plugins = with pkgs.vimPlugins; [
        #jellybeans-vim
	vim-nix
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
        colorscheme base16-scheme
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

  };
  }
