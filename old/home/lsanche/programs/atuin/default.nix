{
  enable = true;
  settings = {
    sync = {
      records = true;
    };
  };
  daemon.enable = true;
  flags = [
    "--disable-up-arrow"
  ];
}
