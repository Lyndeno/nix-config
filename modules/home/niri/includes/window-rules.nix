# kdl
let
  # Liquid-glass parameters for the Niri-glass fork (see overlays/niri-glass.nix).
  # Every background-effect below shares these, so the look is tuned in one place.
  #
  # Aimed at Apple's liquid glass rather than the fork's default frost: the
  # refraction/lens pair bends the backdrop near the edges so the surface reads
  # as a thick pane, edge-lighting picks out the rim, and the adaptive pair keeps
  # content legible by dimming bright backdrops and lifting dark ones.
  glass = ''
    liquid-glass {
                refraction-strength 2.0
                power-factor 6
                refraction-power 0.8
                lens-distortion 0.6
                edge-lighting 0.6
                edge-thickness 0.15
                glow-weight 0.05
                fringing 0.15
                saturation 1.05
                vibrancy 0.2
                adaptive-dim 0.25
                adaptive-boost 0.25
            }'';
in ''
  // Window rules let you adjust behavior for individual windows.
  // Find more information on the wiki:
  // https://github.com/YaLTeR/niri/wiki/Configuration:-Window-Rules
  // Work around WezTerm's initial configure bug
  // by setting an empty default-column-width.
  window-rule {
      // This regular expression is intentionally made as specific as possible,
      // since this is the default config, and we want no false positives.
      // You can get away with just app-id="wezterm" if you want.
      match app-id="^org\\.wezfurlong\\.wezterm$"
      default-column-width {

      }
  }
  window-rule {
      match app-id="^com\\.gabm\\.satty$"
      open-floating true
  }
  // Open aerc HTML email previews in qutebrowser as floating.
  window-rule {
      match app-id="^qutebrowser-aerc$"
      open-floating true
      default-window-height {
          proportion 0.7
      }
      default-column-width {
          proportion 0.7
      }
      focus-ring {
          active-color "#ffffff"
      }
  }
  // Open the Firefox picture-in-picture player as floating by default.
  window-rule {
      // This app-id regular expression will work for both:
      // - host Firefox (app-id is "firefox")
      // - Flatpak Firefox (app-id is "org.mozilla.firefox")
      match app-id="firefox$" title="^Picture-in-Picture$"
      open-floating true
      default-floating-position x=32 y=32 relative-to="bottom-left"
  }
  // Indicate screencasted windows with red colors.
  window-rule {
      match is-window-cast-target=true
      focus-ring {
          active-color "#f38ba8"
          inactive-color "#7d0d2d"
      }
      border {
          inactive-color "#7d0d2d"
      }
      shadow {
          color "#7d0d2d70"
          spread 20
      }
      tab-indicator {
          active-color "#f38ba8"
          inactive-color "#7d0d2d"
      }
  }
  // Example: block out two password managers from screen capture.
  window-rule {
      match app-id="^org\\.keepassxc\\.KeePassXC$"
      match app-id="^org\\.gnome\\.World\\.Secrets$"
      match app-id="1password$"
      block-out-from "screen-capture"
   // Use this instead if you want them visible on third-party screenshot tools.
      // block-out-from "screencast"
  }
  window-rule {
      // Match by "dropdown" app ID.
      // You need to set this app ID when running your terminal, e.g.:
      // spawn "alacritty" "--class" "dropdown"
      match app-id="^hover$"
      // Open it as floating.
      open-floating true
      // Anchor to the top edge of the screen.
      // default-floating-position x=0 y=0 relative-to="top"
      // Half of the screen high.
      default-window-height {
          proportion 0.8
      }
      // 80% of the screen wide.
      default-column-width {
          proportion 0.8
      }
      draw-border-with-background false
      background-effect {
          blur true
          ${glass}
      }
  }
  window-rule {
      match is-floating=true
      background-effect {
          xray false
      }
  }
  window-rule {
      match app-id="^Alacritty$"
      draw-border-with-background false
      background-effect {
          blur true
          ${glass}
      }
  }
  // Block out mako notifications from screencasts.
  layer-rule {
      match namespace="^notifications$"
      block-out-from "screencast"
      background-effect {
          blur true
          ${glass}
          xray false
      }
  }
  layer-rule {
      match namespace="^launcher$"
      background-effect {
          blur true
          ${glass}
          xray false
      }
  }
  layer-rule {
      match namespace="^awww-daemon$"
      place-within-backdrop true
  }
  layer-rule {
      match namespace="^waybar$"
      background-effect {
          blur true
          ${glass}
      }
      popups {
          geometry-corner-radius 6
          opacity 0.85
          background-effect {
              blur true
              ${glass}
              xray false
          }
      }
  }
  layer-rule {
      match layer="top"
      match layer="overlay"
      background-effect {
          blur true
          ${glass}
          xray false
      }
  }
  layer-rule {
      match namespace="^selection$"
      background-effect {
          blur false
          xray false
      }
  }
  // Example: enable rounded corners for all windows.
  // (This example rule is commented out with a "/-" in front.)
  window-rule {
      geometry-corner-radius 12
      clip-to-geometry true
  }
  // These apps draw a translucent sidebar or tab bar (see modules/home/wlroots/gtk.nix
  // and modules/home/qutebrowser/default.nix); blur what shows through it.
  window-rule {
      match app-id="^org\\.gnome\\.Nautilus$"
      match app-id="^org\\.gnome\\.Fractal$"
      // Matches the aerc preview windows (app-id "qutebrowser-aerc") too.
      match app-id="qutebrowser"
      draw-border-with-background false
      background-effect {
          blur true
          ${glass}
      }
      // Menus are separate surfaces, so niri can blur what is under them.
      // The radius matches libadwaita's $popover_radius so the blur follows the
      // menu's own rounded corners instead of squaring them off.
      popups {
          geometry-corner-radius 15
          background-effect {
              blur true
              ${glass}
          }
      }
  }
''
