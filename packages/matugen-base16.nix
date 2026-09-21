{pkgs, ...}: let
  # Tera template (matugen's template syntax) rendering a base16-schemes-compatible
  # YAML file, in the same shape as the files in inputs.base16-schemes.
  #
  # Rather than matugen's own base16 generator (the "wal" backend, which just
  # k-means-clusters the image's raw pixels and can end up monochrome if the
  # image is dominated by one hue), base16 slots are mapped onto matugen's
  # Material You colour roles instead, mirroring the approach in
  # https://github.com/nix-community/stylix/pull/892 (stylix/palette.nix).
  # Material's roles are spread deliberately around the colour wheel
  # (primary/secondary/tertiary/error), so the result has real variety
  # regardless of the source image's colour distribution.
  #
  # Deviates from the PR's dark-mode table in three slots (base07/0C/0D):
  # theirs used `primary` for base07 and `surface_tint`/`primary_fixed` for
  # base0C/0D, but `surface_tint` is *always* identical to `primary` by the
  # Material spec, and `on_surface`/base05 was already `on_surface`'s
  # neighbour tone — so base07 (bright/bold foreground, per Alacritty's
  # target) came out byte-identical to base0B/base0D (ANSI green/blue).
  # Anything highlighted in green or blue (e.g. aerc's selected-row style)
  # became invisible against plain bold text. base07 now reuses `on_surface`
  # (a neutral, like base05) and base0C/0D use `tertiary_container`/
  # `primary_container` so every slot is a genuinely distinct hex value.
  # (`secondary_container` was tried for base0D too, but Material's
  # `*_container` roles are deliberately dark background fills in dark
  # mode, not legible foreground tones — it rendered as a near-black brown
  # wherever an app used it as syntax-highlighting text. `primary_container`
  # keeps the same hue family at a readable brightness instead.)
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
    meta.description = "POC: base16 colour scheme (dark) generated from the wallpaper via matugen";
  } ''
    cp ${pkgs.wallpaper} wallpaper.jpg

    # matugen resolves a relative output_path against the config file's own
    # directory rather than the cwd, so a config living in the (read-only)
    # nix store must point at an absolute, writable output_path ($out).
    # HOME must also point somewhere writable, since matugen caches
    # generated schemes under $HOME/.cache.
    export HOME="$TMPDIR"
    cat > config.toml <<EOF
    [config]

    [templates.base16]
    input_path = "${template}"
    output_path = "$out"
    EOF

    # --source-color-index avoids matugen's interactive source-color picker,
    # which otherwise requires a TTY and would hang/fail in the build sandbox.
    matugen image wallpaper.jpg \
      -m dark \
      --source-color-index 0 \
      -t scheme-content \
      --contrast 0 \
      --resize-filter lanczos3 \
      -c config.toml
  ''
