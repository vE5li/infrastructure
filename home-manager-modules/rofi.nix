{
  pkgs,
  config,
  ...
}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      configuration = {
        font = "monospace 7";
      };

      "*" = {
        highlight = mkLiteral "bold italic #${config.colorScheme.palette.base0D}";
        scrollbar = true;

        background-color = mkLiteral "#${config.colorScheme.palette.base00}";

        alternate-normal-background = mkLiteral "#${config.colorScheme.palette.base01}";
        alternate-normal-foreground = mkLiteral "#${config.colorScheme.palette.base05}";
        selected-normal-background = mkLiteral "#${config.colorScheme.palette.base02}";
        selected-normal-foreground = mkLiteral "#${config.colorScheme.palette.base07}";

        alternate-active-background = mkLiteral "#${config.colorScheme.palette.base02}";
        alternate-active-foreground = mkLiteral "#${config.colorScheme.palette.base05}";
        selected-active-background = mkLiteral "#${config.colorScheme.palette.base0A}";
        selected-active-foreground = mkLiteral "#${config.colorScheme.palette.base07}";

        alternate-urgent-background = mkLiteral "#${config.colorScheme.palette.base04}";
        alternate-urgent-foreground = mkLiteral "#${config.colorScheme.palette.base05}";
        selected-urgent-background = mkLiteral "#${config.colorScheme.palette.base06}";
        selected-urgent-foreground = mkLiteral "#${config.colorScheme.palette.base07}";
      };

      window = {
        background-color = mkLiteral "#${config.colorScheme.palette.base00}";
        padding = mkLiteral "4 10 4 10";
        border-radius = mkLiteral "3";
        width = mkLiteral "50%";
      };

      mainbox = {
        border = mkLiteral "0";
        padding = mkLiteral "0";
      };

      message = {
        border = mkLiteral "2px 0 0";
        padding = mkLiteral "1px";
      };

      textbox = {
        highlight = mkLiteral "@highlight";
        text-color = mkLiteral "#${config.colorScheme.palette.base0F}";
      };

      listview = {
        border = mkLiteral "2px solid 0 0";
        padding = mkLiteral "2px 0 0";
        spacing = mkLiteral "2px";
        scrollbar = mkLiteral "@scrollbar";
        lines = mkLiteral "26";
      };

      element = {
        border = mkLiteral "0";
        padding = mkLiteral "2px";
      };

      "element.normal.normal" = {
        background-color = mkLiteral "#${config.colorScheme.palette.base00}";
        text-color = mkLiteral "#${config.colorScheme.palette.base05}";
      };

      "element.normal.urgent" = {
        background-color = mkLiteral "#${config.colorScheme.palette.base04}";
        text-color = mkLiteral "#${config.colorScheme.palette.base05}";
      };

      "element.normal.active" = {
        background-color = mkLiteral "#${config.colorScheme.palette.base02}";
        text-color = mkLiteral "#${config.colorScheme.palette.base05}";
      };

      "element.selected.normal" = {
        background-color = mkLiteral "@selected-normal-background";
        text-color = mkLiteral "@selected-normal-foreground";
      };

      "element.selected.urgent" = {
        background-color = mkLiteral "@selected-urgent-background";
        text-color = mkLiteral "@selected-urgent-foreground";
      };

      "element.selected.active" = {
        background-color = mkLiteral "@selected-active-background";
        text-color = mkLiteral "@selected-active-foreground";
      };

      "element.alternate.normal" = {
        background-color = mkLiteral "@alternate-normal-background";
        text-color = mkLiteral "@alternate-normal-foreground";
      };

      "element.alternate.urgent" = {
        background-color = mkLiteral "@alternate-urgent-background";
        text-color = mkLiteral "@alternate-urgent-foreground";
      };

      "element.alternate.active" = {
        background-color = mkLiteral "@alternate-active-background";
        text-color = mkLiteral "@alternate-active-foreground";
      };

      scrollbar = {
        width = mkLiteral "4px";
        border = mkLiteral "0";
        handle-width = mkLiteral "8px";
        padding = mkLiteral "0";
      };

      mode-switcher = {
        border = mkLiteral "2px 0 0";
      };

      inputbar = {
        spacing = mkLiteral "0";
        text-color = mkLiteral "#${config.colorScheme.palette.base05}";
        padding = mkLiteral "2px";
        children = map mkLiteral ["prompt" "textbox-prompt-sep" "entry" "case-indicator"];
      };

      prompt = {
        spacing = mkLiteral "0";
        text-color = mkLiteral "#${config.colorScheme.palette.base0E}";
      };

      case-indicator = {
        spacing = mkLiteral "0";
        text-color = mkLiteral "#${config.colorScheme.palette.base0A}";
        blink = mkLiteral "false";
      };

      entry = {
        spacing = mkLiteral "0";
        text-color = mkLiteral "#${config.colorScheme.palette.base0A}";
        blink = mkLiteral "false";
      };

      button = {
        spacing = mkLiteral "0";
        text-color = mkLiteral "#${config.colorScheme.palette.base0A}";
        blink = mkLiteral "false";
      };

      entry = {
        cursor-color = mkLiteral "#${config.colorScheme.palette.base03}";
        cursor-width = mkLiteral "8";
      };

      "button.selected" = {
        background-color = mkLiteral "@selected-normal-background";
        text-color = mkLiteral "@selected-normal-foreground";
      };

      textbox-prompt-sep = {
        expand = mkLiteral "false";
        str = ":";
        text-color = mkLiteral "#${config.colorScheme.palette.base05}";
        margin = mkLiteral "0 0.3em 0 0";
      };

      element-text = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      element-icon = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };
    };
  };
}
