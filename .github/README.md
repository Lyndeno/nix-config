My nixos config

Stuff needed:

before install, two channels need to be added for home-manager and impermanence:
eg:
sudo nix-channel --add https://github.com/nix-community/impermanence/archive/master.tar.gz impermanence
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager
sudo nix-channel --update

Choose home-manager channel that matches that of the nixos channel.