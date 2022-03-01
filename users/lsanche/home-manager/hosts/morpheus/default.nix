{ config, lib, pkgs, ...}:
{
    wayland.windowManager.sway.config = {
        output = {
            DP-1 = {
                adaptive_sync = "on";
                pos = "1920 0";
                mode = "2560x1440@144.000000Hz";
            };
            DP-2 = {
                pos = "0 300";
            };
        };

        workspaceOutputAssign = 
        let
            ws = space: display: { workspace = space; output = display; };
        in
        [
            (ws "1" "DP-1")
            (ws "2" "DP-1")
            (ws "3" "DP-1")
            (ws "4" "DP-1")
            (ws "5" "DP-1")
            (ws "6" "DP-2")
            (ws "7" "DP-2")
            (ws "8" "DP-2")
            (ws "9" "DP-2")
        ];
    };
}