{
  pkgs,
  lib,
  config,
  ...
}: {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        # Show notifications on the focused screen
        follow = "keyboard";

        # Don't sort messages by urgency
        sort = "no";

        # Don't show age of messages
        show_age_threshold = -1;

        # Font
        font = "Monospace 7";
        line_height = 9;

        # Message formatting
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";

        # Split notifications into multiple lines
        word_wrap = "yes";

        # Don't ignore newlines
        ignore_newline = "no";

        # Don't stack together notifications with the same content
        stack_duplicates = false;

        # Display indicators for URLs (U) and actions (A).
        show_indicators = "yes";

        # Maximum amount of notifications kept in history
        history_length = 50;

        # Opening applications
        dmenu = "rofi -show run";
        browser = lib.getExe pkgs.firefox;

        # Window attributes
        title = "Dunst";
        class = "Dunst";

        # Don't let any application close the notification early
        ignore_dbusclose = true;

        # Mouse actions
        mouse_left_click = "do_action, close_current";
        mouse_right_click = "close_current";
        mouse_middle_click = "close_all";

        # Colors
        background = "#${config.colorScheme.palette.base00}";
        frame_color = "#${config.colorScheme.palette.base01}";
        foreground = "#${config.colorScheme.palette.base05}";

        # Separator
        separator_color = "frame";
        separator_height = 2;

        # Padding
        text_icon_padding = 0;
        horizontal_padding = 12;
        padding = 12;

        # Give the Dunst window a 2 pixel outline
        frame_width = 2;

        # Rounded corners
        corner_radius = 4;

        # Never remove notifications automatically
        timeout = 0;
      };
      urgency_critical = {
        # Colors
        background = "#${config.colorScheme.palette.base08}";
        frame_color = "#${config.colorScheme.palette.base09}";
        foreground = "#${config.colorScheme.palette.base06}";
      };
    };
  };

  # FIX: For some reason dunst does not create a service.
  wayland.windowManager.sway.config.startup = [
    {command = "${lib.getExe config.services.dunst.package}";}
  ];
}
