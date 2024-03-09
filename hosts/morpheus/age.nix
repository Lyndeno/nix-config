{secrets}: {
  secrets = with secrets; {
    id_borgbase.file = id_borgbase;
    pass_borgbase.file = morpheus.pass_borgbase;

    id_trinity_borg.file = morpheus.id_trinity_borg;
    pass_trinity_borg.file = morpheus.pass_trinity_borg;
  };
}
