{flake}: {
  secrets = with flake.lib.secretPaths; {
    id_borgbase.file = id_borgbase;
    pass_borgbase.file = neo.pass_borgbase;

    id_trinity_borg.file = neo.id_trinity_borg;
    pass_trinity_borg.file = neo.pass_trinity_borg;
  };
}
