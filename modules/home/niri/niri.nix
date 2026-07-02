''
  // This config is in the KDL format: https://kdl.dev
  // "/-" comments out the following node.
  // Check the wiki for a full description of the configuration:
  // https://github.com/YaLTeR/niri/wiki/Configuration:-Overview

  // You can configure outputs by their name, which you can find
  // by running `niri msg outputs` while inside a niri instance.
  // The built-in laptop monitor is usually called "eDP-1".
  // Find more information on the wiki:
  // https://github.com/YaLTeR/niri/wiki/Configuration:-Outputs
  // Remember to uncomment the node by removing "/-"!
  /-output "eDP-1" {
      // Uncomment this line to disable this output.
      // off

      // Resolution and, optionally, refresh rate of the output.
      // The format is "<width>x<height>" or "<width>x<height>@<refresh rate>".
      // If the refresh rate is omitted, niri will pick the highest refresh rate
      // for the resolution.
      // If the mode is omitted altogether or is invalid, niri will pick one automatically.
      // Run `niri msg outputs` while inside a niri instance to list all outputs and their modes.
      mode "1920x1080@120.030"

      // You can use integer or fractional scale, for example use 1.5 for 150% scale.
      scale 2

      // Transform allows to rotate the output counter-clockwise, valid values are:
      // normal, 90, 180, 270, flipped, flipped-90, flipped-180 and flipped-270.
      transform "normal"

      // Position of the output in the global coordinate space.
      // This affects directional monitor actions like "focus-monitor-left", and cursor movement.
      // The cursor can only move between directly adjacent outputs.
      // Output scale and rotation has to be taken into account for positioning:
      // outputs are sized in logical, or scaled, pixels.
      // For example, a 3840×2160 output with scale 2.0 will have a logical size of 1920×1080,
      // so to put another output directly adjacent to it on the right, set its x to 1920.
      // If the position is unset or results in an overlap, the output is instead placed
      // automatically.
      position x=1280 y=0
  }

  // Add lines like this to spawn processes at startup.
  // Note that running niri as a session supports xdg-desktop-autostart,
  // which may be more convenient to use.
  // See the binds section below for more spawn examples.
  // spawn-at-startup "alacritty" "-e" "fish"
  spawn-at-startup "1password" "--silent"

  // Uncomment this line to ask the clients to omit their client-side decorations if possible.
  // If the client will specifically ask for CSD, the request will be honored.
  // Additionally, clients will be informed that they are tiled, removing some client-side rounded corners.
  // This option will also fix border/focus ring drawing behind some semitransparent windows.
  // After enabling or disabling this, you need to restart the apps for this to take effect.
  prefer-no-csd

  // You can change the path where screenshots are saved.
  // A ~ at the front will be expanded to the home directory.
  // The path is formatted with strftime(3) to give you the screenshot date and time.
  screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

  // You can also set this to null to disable saving screenshots to disk.
  // screenshot-path null

  // Animation settings.
  // The wiki explains how to configure individual animations:
  // https://github.com/YaLTeR/niri/wiki/Configuration:-Animations
  animations {
      // Uncomment to turn off all animations.
      // off

      // Slow down all animations by this factor. Values below 1 speed them up instead.
      // slowdown 3.0
  }
''
