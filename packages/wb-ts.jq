[.Peer[] | select(.ExitNodeOption == true)] as $exit_nodes
| (($exit_nodes[] | select(.ExitNode) | .HostName) // "") as $active
| ($exit_nodes | map(.HostName | length) | max // 0) as $width
| {
    text: $active,
    tooltip: (
      if ($exit_nodes | length) == 0
      then "No exit nodes available"
      else $exit_nodes
        | map(
            (.HostName + (" " * ($width - (.HostName | length))) + " (" + (.TailscaleIPs[0] // "?") + ")") as $line
            | if .ExitNode then "<b><i>" + $line + "</i></b>" else $line end
          )
        | join("\n")
      end
    )
  }
