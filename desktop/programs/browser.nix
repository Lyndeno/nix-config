{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home-manager.users.lsanche = {
    home.sessionVariables.BROWSER = "brave";
    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      extensions = [
        {id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";} # 1password
        {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # Sponsorblock
        {id = "bmnlcjabgnpnenekpadlanbbkooimhnj";} # Paypal Honey
      ];
    };
  };
}
