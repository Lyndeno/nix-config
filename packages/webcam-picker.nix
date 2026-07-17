{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [v4l-utils fuzzel];

    text = ''
      declare -A cam_to_dev=()
      cam_names=()
      current_cam=""

      while IFS= read -r line; do
          if [[ "$line" =~ ^[^[:space:]] ]]; then
              current_cam="''${line% (*}"
              current_cam="''${current_cam%:}"
          elif [[ "$line" =~ ^[[:space:]]*/dev/video[0-9]+ ]]; then
              dev="''${line//[[:space:]]/}"
              if [[ -n "$current_cam" ]] && [[ ! -v "cam_to_dev[$current_cam]" ]]; then
                  cam_to_dev["$current_cam"]="$dev"
                  cam_names+=("$current_cam")
              fi
          fi
      done < <(v4l2-ctl --list-devices 2>/dev/null)

      if [[ ''${#cam_names[@]} -eq 0 ]]; then exit 1; fi

      selected_cam=$(printf '%s\n' "''${cam_names[@]}" | fuzzel --dmenu --prompt="Webcam: ")
      if [[ -z "$selected_cam" ]]; then exit 0; fi

      selected_dev="''${cam_to_dev[$selected_cam]}"

      format_entries=()
      current_fmt=""
      fmt_re="'([A-Z0-9]+)'"
      size_re='Size: Discrete ([0-9]+x[0-9]+)'

      while IFS= read -r line; do
          if [[ "$line" =~ $fmt_re ]]; then
              current_fmt="''${BASH_REMATCH[1]}"
          elif [[ "$line" =~ $size_re ]]; then
              if [[ -n "$current_fmt" ]]; then
                  format_entries+=("$current_fmt ''${BASH_REMATCH[1]}")
              fi
          fi
      done < <(v4l2-ctl -d "$selected_dev" --list-formats-ext 2>/dev/null)

      if [[ ''${#format_entries[@]} -eq 0 ]]; then exit 1; fi

      mapfile -t format_entries < <(printf '%s\n' "''${format_entries[@]}" | sort -u)

      selected_fmt=$(printf '%s\n' "''${format_entries[@]}" | fuzzel --dmenu --prompt="Format: ")
      if [[ -z "$selected_fmt" ]]; then exit 0; fi

      fmt_code="''${selected_fmt%% *}"
      resolution="''${selected_fmt#* }"

      case "$fmt_code" in
          MJPG) ffmpeg_fmt="mjpeg" ;;
          YUYV) ffmpeg_fmt="yuyv422" ;;
          H264) ffmpeg_fmt="h264" ;;
          *)    ffmpeg_fmt="''${fmt_code,,}" ;;
      esac

      ${lib.getExe pkgs.mpv} "av://v4l2:$selected_dev" \
          --profile=low-latency \
          --untimed \
          --cache=no \
          --force-seekable=no \
          --panscan=1 \
          --no-osc \
          --demuxer-lavf-o="video_size=$resolution,input_format=$ffmpeg_fmt" \
          --wayland-app-id=hover
    '';

    meta.platforms = lib.platforms.linux;
  }
