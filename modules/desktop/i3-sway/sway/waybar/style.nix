fontName:
''
* {
    border: none;
    border-radius: 0;
    font-family: ${fontName};
    font-size: 15px;
    min-height: 25px;
    padding: 0px 3px;
		color: @base07;
}

.modules-left {
    padding-left: 6px;
    margin-top: 0px;
    margin-bottom: 0px;
}

.modules-right {
    padding-right: 6px;
    margin-top: 0px;
    margin-bottom: 0px;
}

#waybar {
    background: @base01;
}

#custom-separator {
    padding: 0px 0px;
    margin: 0px 5px;
}



#workspaces button {
    margin: 0px 0px;
    background: @base01;
    color: #cccccc;
    min-width: 20px;
    /*border-radius: 15px;*/
}

#workspaces button.focused {
    background: @base02;
}

#workspaces button:hover {
    background: @base05;
}

#mode {
    background: #64727D;
}

/* Groups and single items */

#cpu, #memory {
    color: @base08;
}

#disk.root, #disk.xpsroot, #disk.mirror {
    color: @base0B;
}

#network, #custom-pia-status {
    color: @base05;
}

#idle_inhibitor, #pulseaudio, #tray {
    color: @base05;
}

#workspaces {
    color: @base02;
}

#clock {
    color: @base07;
    font-size: 16px;
}

#custom-gamemode {
    background: #61d42c;
    color: black;
}

#custom-checkdots {
    color: #00c3ff;
}

#custom-checkupdate {
    color: #ffa600;
}

/* Right Side */
#disk.mirror, #disk.xpsroot, #custom-pia-status, 
#tray, #clock, #custom-checkdots, #custom-checkupdate, #workspaces, #custom-media, 
#mode, #custom-gamemode, #memory, #memory.xps, #backlight {
	margin-right: 5px;
}

/* Left Sides */

#cpu, #disk.root, #disk.xpsroot, #network, #pulseaudio, #clock, #custom-checkdots, #custom-checkupdate,
#workspaces, #custom-media, #mode, #custom-gamemode, #battery {
	margin-left: 5px;
}



/* Other settings */

#battery.warning {
	color: @base0A;
}

#battery.critical {
	color: @base08;
}

#disk.root.warning, #disk.mirror.warning {
    color: @base0A;
}

#disk.root.high, #disk.mirror.high {
    color: @base09;
}

#disk.root.critical, #disk.mirror.critical {
    color: @base08;
}

#temperature.critical {
    color: @base08;
}

@keyframes blink {
    to {
        background-color: @base07;
        color: @base00;
    }
}

/* Secondary monitor specific options*/
/*window.DP-2 * {
    padding: 0;
}

window.DP-2 #window {
    padding: 0px;
}

window.DP-2 #workspaces {
    padding: 0px;
}

window.DP-2 #clock {
    background-color: transparent;
    color: #ffffff;
    padding: 0px;

    border-style: none;
}

window.DP-2 #workspaces {
    padding-left: 0px;
}*/
''