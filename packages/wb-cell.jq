.environment as $e
| ([$e.cellular_signal_level // 0, 0] | max) as $raw
| ([$raw, 4] | min) as $level
| (["󰣾","󰣴","󰣶","󰣸","󰣺"][$level]) as $icon
| ($e.cellular_network_type // "unknown") as $type
| {
    text: ($icon + " " + $type),
    tooltip: ("Cellular: " + $type + "\nSignal: " + ($level | tostring) + "/4")
  }
