{
  pkgs,
  lib,
  config,
  cross-cursor,
  ...
}: let
  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    # Check command line arguments
    if [[ $# != 2 ]]; then
        echo "error: screenshot script expected two parameters"
        echo ""
        echo "usage: screenshot.sh <output directory> <crop>"
        exit 1
    fi

    # Variables
    date=$(date +%Y-%m-%d_%H-%m-%s)
    temp_image_file="$1/$date.png"

    # Take the screenshot
    if [[ "$2" == "true" ]]; then
        ${lib.getExe pkgs.grim} -t png -g "$(${lib.getExe pkgs.slurp})" "$temp_image_file"
    else
        ${lib.getExe pkgs.grim} -t png "$temp_image_file"
    fi

    echo "$date"

    # If the screenshot was aborted, exit the script
    if [[ $? != 0 ]]; then
        exit 1
    fi

    # Get new image name from rofi
    new_name=$(ls $1 -t | sed 's/\.[^.]*$//' | rofi -dmenu)

    # if the name selection was aborted, remove the temp file and exit the script
    if [[ $? != 0 ]]; then
        rm "$temp_image_file"
        exit 1
    fi

    # If the new file name differs from the temporary file name, move the image
    if [[ "$new_name" != "" && "$new_name" != "$date" ]]; then
        new_image_file="$1/$new_name.png"
        mv "$temp_image_file" "$new_image_file"
        ${lib.getExe pkgs.libnotify} "screenshot saved as $new_name.png"
    else
        ${lib.getExe pkgs.libnotify} "screenshot saved as $temp_image_file"
    fi
  '';

  copy = pkgs.writeShellScriptBin "copy" ''
    # Get the app id of the focused window
    app_id=$(${lib.getExe' pkgs.sway "swaymsg"} -t get_tree | ${lib.getExe pkgs.jq} ".. | select(.type?) | select(.focused==true) | .app_id")

    # Don't copy from windows that have the app id "org.keepassxc.KeePassXC"
    if [ $app_id != '"org.keepassxc.KeePassXC"' ]; then
        text=$(${lib.getExe' pkgs.wl-clipboard "wl-paste"} -n)

        if [[ $text != *"BEGIN OPENSSH PRIVATE KEY"* ]]; then
            echo "$text" | ${lib.getExe pkgs.clipman} store --max-items=5000 --no-persist
        fi
    fi
  '';

  # Script to connect to another machine via ssh
  remote-terminal = pkgs.writeShellScriptBin "remote-terminal" ''
    device=$(echo -e "${builtins.concatStringsSep "\n" config.role-configuration.suggested-remote-machines}" | rofi -dmenu)

    # Only open a connection if the selection wasn't aborted
    # Port forward for lemonade.
    if [[ $? == 0 ]]; then
      foot -e ssh -R 2489:localhost:2489 -t $device nvim-terminal &
    fi
  '';
in {
  options.role-configuration = with lib; {
    suggested-remote-machines = mkOption {
      default = [];
      description = "List of other machines that can be opened through a terminal shortcut";
      type = types.listOf types.str;
    };
    wallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = {
    home.packages = with pkgs; [
      clipman
      wl-clipboard
      libnotify
      keepassxc
      # Tools
      inkscape
      obs-studio
    ];

    wayland.windowManager.sway = {
      enable = true;

      config = let
        modifier = "Mod4";
        alt = "Shift";
      in {
        input = {
          "*" = {
            xkb_layout = "de";
          };
        };

        output = lib.mkIf (config.role-configuration.wallpaper != null) {
          "*" = {
            bg = "${config.role-configuration.wallpaper} fill";
          };
        };

        modifier = modifier;

        window = {
          titlebar = false;
          border = 3;
        };
        floating = {
          titlebar = false;
          border = 3;
        };

        bars = [];

        colors = {
          focused = {
            background = "#${config.colorScheme.palette.base00}";
            border = "#${config.colorScheme.palette.base08}";
            childBorder = "#${config.colorScheme.palette.base09}";
            indicator = "#${config.colorScheme.palette.base0A}";
            text = "#ffffff";
          };
        };

        startup = [
          {command = "${lib.getExe' pkgs.wl-clipboard "wl-paste"} -t text --watch ${lib.getExe copy}";}
          {command = "${lib.getExe pkgs.lemonade} server";}
        ];

        up = "up";
        down = "down";
        left = "left";
        right = "right";

        keybindings = {
          # Program launcher
          "${modifier}+v" = "exec rofi -show run";

          # Terminal
          "${modifier}+m" = "exec foot -e nvim-terminal";
          "${modifier}+k" = "exec ${lib.getExe remote-terminal}";

          # Close active window
          "${modifier}+c" = "kill";

          # Exit Sway
          "${modifier}+${alt}+x" = "exit";

          # Toggle window floating
          "${modifier}+f" = "floating toggle";

          # Toggle window fullscreen
          "${modifier}+d" = "fullscreen toggle";

          # Change orientation of the window split
          "${modifier}+h" = "layout toggle split";

          # Screenshots
          "${modifier}+y" = "exec ${lib.getExe screenshot} /home/${config.home.username}/cloud/${config.home.username}/screenshots false";
          "${modifier}+s" = "exec ${lib.getExe screenshot} /home/${config.home.username}/cloud/${config.home.username}/screenshots true";

          # Clipboard manager
          "${modifier}+p" = "exec ${lib.getExe pkgs.clipman} pick -t CUSTOM -T \"rofi -dmenu -p clipboard -i\"";

          # Notifications
          "${modifier}+i" = "exec ${lib.getExe' pkgs.dunst "dunstctl"} close";
          "${modifier}+delete" = "exec ${lib.getExe' pkgs.dunst "dunstctl"} close-all";
          "${modifier}+o" = "exec ${lib.getExe' pkgs.dunst "dunstctl"} history-pop";

          # Move focus inside workspace
          "${modifier}+backspace" = "focus left";
          "${modifier}+r" = "focus right";
          "${modifier}+space" = "focus up";
          "${modifier}+e" = "focus down";

          # Move focus to another workspaces
          "${modifier}+a" = "workspace number 1";
          "${modifier}+return" = "workspace number 2";
          "${modifier}+q" = "workspace number 3";
          "${modifier}+t" = "workspace number 4";

          # Move windows in workspace
          "${modifier}+g" = "move left";
          "${modifier}+w" = "move right";
          "${modifier}+${alt}+minus" = "move up";
          "${modifier}+z" = "move down";

          # Move window to another workspace
          "${modifier}+b" = "move container to workspace number 1";
          "${modifier}+minus" = "move container to workspace number 2";
          "${modifier}+x" = "move container to workspace number 3";
          # "${modifier}+numbersing" = "move container to workspace number 4";
        };

        modes = {};
      };
    };

    home.pointerCursor = {
      package = cross-cursor.packages.${pkgs.system}.default;
      name = "cross-cursor";
      size = 26;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
