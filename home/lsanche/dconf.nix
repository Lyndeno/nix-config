{config}: {
  settings = {
    "org/gnome/desktop/interface" = with config.stylix.fonts; {
      font-name = "${sansSerif.name} ${toString sizes.applications}";
      document-font-name = "${serif.name}  ${toString (sizes.applications - 1)}";
      monospace-font-name = "${monospace.name} ${toString sizes.applications}";
    };
    "org/gnome/mutter" = {
      experimental-features = ["variable-refresh-rate"];
    };
  };
}
