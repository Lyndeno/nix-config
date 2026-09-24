.status as $s | .device as $d | .environment as $e
| ([$s.level / 10 | floor, 10] | min) as $idx
| ["󰠒","󰠈","󰠉","󰠊","󰠋","󰠌","󰠍","󰠎","󰠏","󰠐","󰠇"][$idx] as $level_icon
| (if $s.is_charging then "󰠇" elif $s.level <= 15 then "󰠑" else $level_icon end) as $icon
| {
    text: (
      $icon
      + (if $s.is_charging or $s.level < 50
         then " " + ($s.level | tostring) + "%"
         else "" end)
    ),
    tooltip: (
      $d.model
      + "\nBattery: " + ($s.level | tostring) + "% (" + $s.health + ")"
      + "\nTemp: " + $s.temp
      + "\nPower: " + $s.power_source
      + "\nNetwork: " + $e.data_connection
    ),
    class: [
      (if $s.level <= 15 then "critical" elif $s.level <= 30 then "warning" else empty end),
      (if $s.is_charging then "charging" else empty end)
    ]
  }
