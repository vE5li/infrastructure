{
  lib,
  pkgs,
  config,
  ...
}: let
  helper = import ./helper.nix {inherit lib;};

  # Number of key rows.
  row-count = 4;

  # Number of key columns.
  column-count = 4;

  # Create a light partition.
  light-patrition = index: {
    platform = "partition";
    name = "State ${toString (index + 1)} Light";
    segments = [
      {
        id = "state_light";
        from = index;
        to = index;
      }
    ];
  };

  # Create a matrix key.
  matrix-key = index: let
    row = index / column-count;
    col = index - (row * column-count);
  in {
    platform = "matrix_keypad";
    keypad_id = "keys";
    name = "Key ${toString index}";
    id = "key${toString index}";
    inherit row col;
  };

  # Raw config as Nix.
  controller-config = {
    esphome = {
      name = "controller";
    };

    esp32 = {
      board = "nodemcu-32s";
      framework = {
        type = "arduino";
      };
    };

    logger = {};

    api = {
      password = "";
    };

    ota = {
      platform = "esphome";
      password = "";
    };

    wifi = {
      ssid = helper.ssid-secret;
      password = helper.password-secret;
      use_address = "192.168.188.82";
    };

    status_led = {
      pin = "GPIO2";
    };

    light =
      [
        {
          platform = "neopixelbus";
          variant = "WS2812";
          pin = "GPIO12";
          num_leds = 15;
          type = "GRB";
          name = "WS2812B Light";
          id = "state_light";
          method = {
            type = "esp32_rmt";
          };
        }
      ]
      # Other light partitions (State 1 - State 15)
      # NOTE: The first LED is not part of the LED strip. As such, we subtract one form the number of LEDs.
      ++ builtins.genList (index: light-patrition index) (row-count * column-count - 1);

    matrix_keypad = {
      id = "keys";
      columns = [
        {pin = "GPIO14";}
        {pin = "GPIO27";}
        {pin = "GPIO26";}
        {pin = "GPIO25";}
      ];
      rows = [
        {pin = "GPIO5";}
        {pin = "GPIO18";}
        {pin = "GPIO19";}
        {pin = "GPIO21";}
      ];
    };

    # NOTE: The first key is not part of the matrix. As such, we subtract one form the number of keys and add one to the index on each invocation.
    binary_sensor = builtins.genList (index: matrix-key (index + 1)) (row-count * column-count - 1);

    uart = [
      {
        id = "desk_uart";
        baud_rate = 9600;
        tx_pin = "GPIO17";
        rx_pin = "GPIO16";
      }
    ];

    sensor = [
      {
        platform = "wifi_signal";
        name = "WiFi Signal";
        update_interval = "60s";
      }
      {
        platform = "uptime";
        name = "Uptime";
      }
    ];

    switch = [
      {
        platform = "uart";
        name = "Preset 1";
        id = "switch_preset1";
        icon = "mdi:numeric-1-box";
        data = [155 6 2 4 0 172 163 157];
        uart_id = "desk_uart";
      }
      {
        platform = "uart";
        name = "Preset 2";
        id = "switch_preset2";
        icon = "mdi:numeric-2-box";
        data = [155 6 2 8 0 172 166 157];
        uart_id = "desk_uart";
      }
      {
        platform = "uart";
        name = "Preset 3";
        id = "switch_preset3";
        icon = "mdi:numeric-3-box";
        data = [155 6 2 16 0 172 172 157];
        uart_id = "desk_uart";
      }
      {
        platform = "uart";
        name = "Up";
        id = "switch_up";
        icon = "mdi:arrow-up-bold";
        data = [155 6 2 1 0 252 160 157];
        uart_id = "desk_uart";
      }
      {
        platform = "uart";
        name = "Down";
        id = "switch_down";
        icon = "mdi:arrow-down-bold";
        data = [155 6 2 2 0 12 160 157];
        uart_id = "desk_uart";
      }
      {
        platform = "uart";
        name = "M";
        id = "switch_m";
        icon = "mdi:alpha-m-circle";
        data = [155 6 2 32 0 172 184 157];
        uart_id = "desk_uart";
      }
      {
        platform = "uart";
        name = "(wake up)"; # Not available on all control panels
        id = "switch_wake_up";
        icon = "mdi:gesture-tap-button";
        data = [155 6 2 0 0 108 161 157];
        uart_id = "desk_uart";
      }
    ];
  };

  controller-yaml = helper.to-yaml controller-config;

  upload-controller = pkgs.writeShellScriptBin "upload-controller" ''
    ${lib.getExe pkgs.esphome} compile /home/${config.home.username}/esphome/controller.yaml
    ${lib.getExe pkgs.esphome} upload /home/${config.home.username}/esphome/controller.yaml
  '';
in {
  home.packages = [upload-controller];

  home.file."esphome/controller.yaml".text = controller-yaml;

  home.activation.linkSecret = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sf /run/agenix/esphome-secrets.yaml /home/${config.home.username}/esphome/secrets.yaml
  '';
}
