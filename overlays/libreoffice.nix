_final: prev: {
  # libreoffice is hiPrio libreoffice-still, so overriding here covers both.
  libreoffice-still = prev.lib.lowPrio (prev.libreoffice-still.override {
    unwrapped = prev.libreoffice-still.unwrapped.override {
      # Drops ~850 MiB of offline help; F1 falls back to help.libreoffice.org.
      withHelp = false;
      # UI translations for 27 languages by default; only English is used.
      langs = ["en-US"];
    };
  });
}
