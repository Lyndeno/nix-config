{
  config,
  lib,
  ...
}: {
  # Referenced https://github.com/base16-project/base16-fzf/blob/main/templates/default.mustache
  home-manager.users.lsanche.programs.fzf = {
    enable = true;
    defaultOptions = with config.lib.stylix.colors.withHashtag; [
      "--color=spinner:${base0C},hl:${base0D}"
      "--color=fg:${base04},header:${base0D},info:${base0A},pointer:${base0C}"
      "--color=marker:${base0C},fg+:${base06},prompt:${base0A},hl+:${base0D}"
    ];
  };
}
