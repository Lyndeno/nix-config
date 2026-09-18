{
  config,
  lib,
  ...
}: let
  inherit (config.lib.stylix) colors;
  inherit (config.stylix) opacity;

  # GTK's alpha() takes a colour and a factor, so stylix's opacities map straight over.
  translucent = alpha: color: "alpha(#${color}, ${toString alpha})";

  # AdwOverlaySplitView renames its children depending on the layout: wide
  # windows get .sidebar-pane/.content-pane, collapsed ones get .background on
  # the overlay sidebar and no class at all on the content.
  sidebarPane = ".sidebar-pane";
  collapsedSidebarPane = "overlay-split-view > widget.background";
  contentPane = "overlay-split-view > widget:not(.sidebar-pane):not(.background)";

  # Everything that paints its own background inside the sidebar, and so would
  # otherwise cover the pane's own colour.
  sidebarChildren = [
    ""
    " headerbar"
    " headerbar > windowhandle > box"
    " .toolbar"
    " placessidebar"
    " scrolledwindow"
    " listview"
    " list"
    " .navigation-sidebar"
  ];

  selectors = lib.concatMapStringsSep ",\n" (s: "window.nautilus-window ${s}");
in {
  # Nautilus has no transparency of its own, so the sidebar is made see-through
  # here and niri blurs whatever shows through it (see the window rule in
  # modules/home/niri/includes/window-rules.kdl).
  #
  # The toplevel is cleared along with every widget that paints inside the
  # sidebar pane, then the pane itself is repainted translucent and the content
  # pane is repainted opaque so only the sidebar lets the blur through.
  #
  # Collapsed, the sidebar becomes an overlay on top of the (opaque) content
  # rather than a hole through to the desktop, so there is nothing behind it for
  # niri to blur; it is painted opaque there instead of translucent.
  stylix.targets.gtk.extraCss = ''
    window.nautilus-window.background,
    window.nautilus-window.view,
    window.nautilus-window > widget,
    ${selectors (lib.concatMap
      (pane: map (child: pane + child) sidebarChildren)
      [sidebarPane collapsedSidebarPane])} {
      background-color: transparent;
      background-image: none;
    }

    window.nautilus-window ${sidebarPane} {
      background-color: ${translucent opacity.desktop colors.base01};
    }

    window.nautilus-window ${collapsedSidebarPane} {
      background-color: #${colors.base01};
    }

    window.nautilus-window ${contentPane} {
      background-color: #${colors.base00};
    }

    /* Menus are their own surfaces, so niri blurs what sits under them
       (see the popups block in the niri window rule). */
    window.nautilus-window popover > arrow,
    window.nautilus-window popover > contents {
      background-color: ${translucent opacity.popups colors.base01};
    }
  '';
}
