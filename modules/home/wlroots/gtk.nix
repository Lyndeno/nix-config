{
  config,
  lib,
  ...
}: let
  inherit (config.lib.stylix) colors;
  inherit (config.stylix) opacity;

  # GTK's alpha() takes a colour and a factor, so stylix's opacities map straight over.
  translucent = alpha: color: "alpha(#${color}, ${toString alpha})";

  # Style classes the apps put on their own windows. GTK adds nothing
  # app-specific, and libadwaita apps ignore GTK themes, so gtk-4.0/gtk.css is
  # the only hook available and everything below has to be scoped by hand.
  # Nautilus tags its window upstream; Fractal is tagged by patches/fractal.patch.
  windows = [
    "window.nautilus-window"
    "window.fractal-window"
  ];

  # The split views rename their children depending on the layout. Uncollapsed,
  # both flavours use .sidebar-pane/.content-pane. Collapsed, AdwOverlaySplitView
  # puts .background on the overlay sidebar and no class on the content, while
  # AdwNavigationSplitView drops the panes entirely for a single navigation-view.
  sidebarPane = ".sidebar-pane";
  collapsedSidebarPane = "overlay-split-view > widget.background";
  contentPanes = [
    "overlay-split-view > widget:not(.sidebar-pane):not(.background)"
    "navigation-split-view > widget.content-pane"
    "navigation-split-view > navigation-view"
  ];

  # Everything that paints its own background inside a sidebar, and so would
  # otherwise cover the pane's own colour.
  sidebarChildren = [
    ""
    " headerbar"
    " headerbar > windowhandle > box"
    " searchbar > revealer > box"
    " .toolbar"
    " placessidebar"
    " sidebar"
    " scrolledwindow"
    " listview"
    " list"
    " .navigation-sidebar"
  ];

  # One selector per window, for each of the given trailing selectors.
  scoped = sep: parts:
    lib.concatMapStringsSep ",\n"
    (part: part.window + sep + part.rest)
    (lib.cartesianProduct {
      window = windows;
      rest = parts;
    });

  # .background and .view sit on the window itself, everything else below it.
  onWindow = scoped "";
  selectors = scoped " ";
in {
  # Neither app has any transparency of its own, so their sidebars are made
  # see-through here and niri blurs whatever shows through them (see the window
  # rules in modules/home/niri/includes/window-rules.kdl).
  #
  # The toplevel is cleared along with every widget that paints inside the
  # sidebar pane, then the pane itself is repainted translucent and the content
  # pane is repainted opaque so only the sidebar lets the blur through.
  #
  # Collapsed, a sidebar is an overlay on top of the (opaque) content rather
  # than a hole through to the desktop, so there is nothing behind it for niri
  # to blur; it is painted opaque there instead of translucent.
  stylix.targets.gtk.extraCss = ''
    ${onWindow [".background" ".view"]},
    ${selectors ["> widget"]},
    ${selectors (map (child: sidebarPane + child) sidebarChildren)},
    ${selectors (map (child: collapsedSidebarPane + child) sidebarChildren)} {
      background-color: transparent;
      background-image: none;
    }

    ${selectors [sidebarPane]} {
      background-color: ${translucent opacity.desktop colors.base01};
    }

    ${selectors [collapsedSidebarPane]} {
      background-color: #${colors.base01};
    }

    ${selectors contentPanes} {
      background-color: #${colors.base00};
    }

    /* Menus are their own surfaces, so niri blurs what sits under them
       (see the popups blocks in the niri window rules). */
    ${selectors ["popover > arrow" "popover > contents"]} {
      background-color: ${translucent opacity.popups colors.base01};
    }
  '';
}
