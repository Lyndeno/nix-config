{
  lib,
  pkgs,
  inputs,
  ...
}: {
  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  nix = {
    settings.auto-optimise-store = true;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 60d";
    };
  };

  programs.dconf.enable = true;

  services = {
    tailscale.enable = true;
    openssh.enable = true;
    syncthing = {
      enable = true;
      user = "lsanche";
      dataDir = "/home/lsanche";
      configDir = "/home/lsanche/.config/syncthing";
      openDefaultPorts = true;
    };
  };

  security.pam = {
    u2f.enable = true;
    u2f.cue = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      pinentryFlavor = lib.mkDefault "curses";
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      enableGlobalCompInit = false;
    };
  };

  stylix = let
    base16Scheme = "${inputs.base16-schemes}/atelier-dune.yaml";
  in {
    image = "${inputs.wallpapers}/starry.jpg";
    inherit base16Scheme;
    targets.grub.enable = false;
    targets.chromium.enable = false;
    fonts = let
      cascadia = pkgs.nerdfonts.override {fonts = ["CascadiaCode"];};
    in {
      serif = {
        package = cascadia;
        name = "CaskaydiaCove Nerd Font";
      };
      sansSerif = {
        package = cascadia;
        name = "CaskaydiaCove Nerd Font";
      };
      monospace = {
        package = cascadia;
        name = "CaskaydiaCove Nerd Font Mono";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    btrfs-progs
    busybox
    screen
  ];
}
