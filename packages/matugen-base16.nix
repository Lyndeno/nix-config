{pkgs, ...}: let
  # Renders a base16-schemes-compatible YAML file (matugen template syntax),
  # mapping base16 slots onto matugen's Material You colour roles rather than
  # matugen's own "wal" backend, which just k-means-clusters raw pixels and
  # can end up monochrome. Mirrors nix-community/stylix#892 (stylix/palette.nix),
  # except base07/0C/0D avoid roles that are identical to others in dark mode
  # (`surface_tint` == `primary`) or too dark to use as foreground text
  # (`*_container` roles).
  template = pkgs.writeText "matugen-base16.yaml.template" ''
    system: "base16"
    name: "matugen"
    author: "matugen (generated)"
    variant: "dark"
    palette:
      base00: "{{colors.surface_container_lowest.default.hex}}"
      base01: "{{colors.surface_container.default.hex}}"
      base02: "{{colors.surface_container_highest.default.hex}}"
      base03: "{{colors.outline.default.hex}}"
      base04: "{{colors.on_surface_variant.default.hex}}"
      base05: "{{colors.on_surface.default.hex}}"
      base06: "{{colors.secondary_fixed.default.hex}}"
      base07: "{{colors.on_surface.default.hex}}"
      base08: "{{colors.error.default.hex}}"
      base09: "{{colors.tertiary.default.hex}}"
      base0A: "{{colors.secondary.default.hex}}"
      base0B: "{{colors.primary.default.hex}}"
      base0C: "{{colors.tertiary_container.default.hex}}"
      base0D: "{{colors.primary_container.default.hex}}"
      base0E: "{{colors.tertiary_fixed.default.hex}}"
      base0F: "{{colors.on_error_container.default.hex}}"
  '';
in
  pkgs.runCommand "matugen-base16-scheme" {
    nativeBuildInputs = [pkgs.matugen];
    meta.description = "Base16 colour scheme (dark) generated from the wallpaper via matugen";
  } ''
    cp ${pkgs.wallpaper} wallpaper.jpg

    # output_path resolves relative to config.toml's own dir (the read-only
    # store), so it must be absolute; HOME must be writable for matugen's cache.
    export HOME="$TMPDIR"
    cat > config.toml <<EOF
    [config]

    [templates.base16]
    input_path = "${template}"
    output_path = "$out"
    EOF

    # --source-color-index avoids matugen's interactive TTY picker.
    matugen image wallpaper.jpg \
      -m dark \
      --source-color-index 0 \
      -t scheme-content \
      --contrast 0 \
      --resize-filter lanczos3 \
      -c config.toml
  ''
