{
  pkgs,
  lib,
  config,
  cross-cursor,
  ...
}: let
  copy = pkgs.writeShellScriptBin "copy" ''
    # Get the app id of the focused window
    app_id=$(${lib.getExe pkgs.niri} msg focused-window | grep "App ID" | sed "s/  App ID: //")

    # Don't copy from windows that have the app id "org.keepassxc.KeePassXC"
    if [ $app_id != '"org.keepassxc.KeePassXC"' ]; then
        text=$(${lib.getExe' pkgs.wl-clipboard "wl-paste"} -n)

        if [[ $text != *"BEGIN OPENSSH PRIVATE KEY"* ]]; then
            echo "$text" | ${lib.getExe pkgs.clipman} store --max-items=5000 --no-persist
        fi
    fi
  '';

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
      description = "Store path to the image used as a wallpaper";
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

    home.pointerCursor = {
      package = cross-cursor.packages.${pkgs.stdenv.hostPlatform.system}.default;
      name = "cross-cursor";
      size = 26;
      gtk.enable = true;
      x11.enable = true;
    };

    programs.niri = {
      settings = {
        hotkey-overlay.skip-at-startup = true;

        # Remove window decorations unless specifically requested.
        prefer-no-csd = true;

        screenshot-path = "/home/${config.home.username}/cloud/${config.home.username}/screenshots/%Y-%m-%d_%H-%M-%S.png";

        input.keyboard.xkb.layout = "de";

        layout = {
          gaps = 18;
          center-focused-column = "never";

          default-column-width.proportion = 1. / 3.;
          preset-column-widths = [
            {proportion = 1. / 3.;}
            {proportion = 1. / 2.;}
            {proportion = 2. / 3.;}
          ];

          focus-ring = {
            width = 3;
            active.gradient = {
              from = config.colorScheme.palette.base0E;
              to = config.colorScheme.palette.base08;
              angle = 45;
            };
          };

          border = {};
        };

        outputs."HDMI-A-1" = {
          scale = 1;
        };

        binds = {
          "Mod+M".action.spawn = ["foot" "-e" "nvim-terminal"];
          "Mod+Shift+M".action.spawn = [(lib.getExe remote-terminal)];

          "Mod+V".action.spawn = ["rofi" "-show" "run"];

          "Mod+K".action.spawn = [(lib.getExe pkgs.clipman) "pick" "-t" "CUSTOM" "-T" "rofi -dmenu -p clipboard -i"];

          "Mod+O" = {
            repeat = false;
            action.toggle-overview = {};
          };

          "Mod+C" = {
            repeat = false;
            action.close-window = {};
          };

          "Mod+A".action.spawn = [(lib.getExe' pkgs.dunst "dunstctl") "close"];
          "Mod+Shift+A".action.spawn = [(lib.getExe' pkgs.dunst "dunstctl") "close-all"];
          "Mod+Z".action.spawn = [(lib.getExe' pkgs.dunst "dunstctl") "history-pop"];

          "Mod+N".action.focus-column-left = {};
          "Mod+E".action.focus-window-down = {};
          "Mod+U".action.focus-window-up = {};
          "Mod+I".action.focus-column-right = {};

          "Mod+Shift+N".action.move-column-left = {};
          "Mod+Shift+E".action.move-window-down = {};
          "Mod+Shift+U".action.move-window-up = {};
          "Mod+Shift+I".action.move-column-right = {};

          "Mod+J".action.focus-workspace-up = {};
          "Mod+L".action.focus-workspace-down = {};

          "Mod+Shift+J".action.move-column-to-workspace-up = {};
          "Mod+Shift+L".action.move-column-to-workspace-down = {};

          "Mod+Shift+V".action.consume-window-into-column = {};
          "Mod+Shift+K".action.expel-window-from-column = {};

          "Mod+R".action.switch-preset-column-width = {};

          "Mod+F".action.maximize-column = {};
          "Mod+Shift+F".action.fullscreen-window = {};

          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Plus".action.set-column-width = "+10%";

          "Mod+T".action.toggle-window-floating = {};
          "Mod+Shift+T".action.switch-focus-between-floating-and-tiling = {};

          "Mod+W".action.toggle-column-tabbed-display = {};

          "Mod+Q".action.screenshot = {};
          "Mod+Shift+Q".action.screenshot-screen = {};
          "Mod+Shift+W".action.screenshot-window = {};

          "Mod+Shift+X".action.quit = {};

          "Mod+Shift+P".action.power-off-monitors = {};
        };

        spawn-at-startup = [
          {
            argv = [
              (lib.getExe' pkgs.wl-clipboard "wl-paste")
              "-t"
              "text"
              "--watch"
              (lib.getExe copy)
            ];
          }
          {
            argv = [
              (lib.getExe pkgs.lemonade)
              "server"
            ];
          }
          {
            argv = [
              (lib.getExe pkgs.wbg)
              config.role-configuration.wallpaper
            ];
          }
        ];
      };
    };
  };
}
