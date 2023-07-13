{pkgs}:
with pkgs;
  [
    wally-cli # for moonlander
    brightnessctl # for brightness control
  ]
  ++ (with plasma5Packages; [
    kmail
    kmail-account-wizard
    kmailtransport
    kalendar
    kaddressbook
    accounts-qt
    kdepim-runtime
    kdepim-addons
    ark
    okular
    filelight
    partition-manager
    plasma-integration
    plasma-browser-integration
    kaccounts-integration
    kaccounts-providers
  ])
