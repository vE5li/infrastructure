{config, ...}: {
  # Bluetooth
  hardware.bluetooth.enable = true;

  services.home-assistant = {
    enable = true;

    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"

      # WLED
      "wled"

      # Zigbee
      "zha"

      # Companion app
      "mobile_app"

      # 3D priter
      "octoprint"

      # Tracking daytime
      "sun"

      #ESPHome
      "esphome"
    ];

    # Allow connecting from other devices on the server_port
    openFirewall = true;

    config = {
      http = {
        server_port = 8123;
        trusted_proxies = ["::1"];
        use_x_forwarded_for = true;
      };

      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};

      automation = let
        # When a state changes.
        state-change = {
          entity_id,
          to,
        }: {
          trigger = "state";
          entity_id = [entity_id];
          inherit to;
        };

        # When a state changes to `on`.
        turned-on = {entity_id}:
          state-change {
            inherit entity_id;
            to = "on";
          };

        # When a state changes to `off`.
        turned-off = {entity_id}:
          state-change {
            inherit entity_id;
            to = "off";
          };

        # Toggle a switch.
        turn-switch-on = target: {
          action = "switch.turn_on";
          inherit target;
        };

        # Toggle a switch.
        turn-switch-off = target: {
          action = "switch.turn_off";
          inherit target;
        };

        # Toggle a light.
        turn-light-on = target: data: {
          action = "light.turn_on";
          inherit data target;
        };

        # Toggle a light.
        turn-light-off = target: {
          action = "light.turn_off";
          inherit target;
        };

        # Wait for change.
        wait-till-available = target: {
          wait_for_trigger = [
            {
              trigger = "state";
              entity_id = target;
              from = "unavailable";
            }
          ];
        };

        # Set the light to the same state as some input.
        set-light-to = {
          input_entity_id,
          target,
          color,
        }: {
          choose = [
            {
              conditions = [
                {
                  condition = "state";
                  entity_id = input_entity_id;
                  state = "on";
                }
              ];
              sequence = [
                {
                  action = "light.turn_on";
                  inherit target;
                  data = {
                    rgb_color = color;
                  };
                }
              ];
            }
            {
              conditions = [
                {
                  condition = "state";
                  entity_id = input_entity_id;
                  state = "off";
                }
              ];
              sequence = [
                {
                  action = "light.turn_off";
                  inherit target;
                }
              ];
            }
          ];
        };

        # Send a notification with an alarm tone to the phone.
        alarm-notification = {
          to,
          message,
        }: {
          action = "notify.mobile_app_${to}_phone";
          metadata = {};
          data = {
            inherit message;
            data = {
              ttl = 0;
              prority = "high";
              channel = "alarm_stream";
            };
          };
        };
      in [
        # Turn computer lighting on.
        {
          alias = "computer lights on";
          description = "Turn on the computers lighting in sequence";
          mode = "restart";
          triggers = [
            (turned-on {entity_id = "input_boolean.computer_lights_toggle";})
          ];
          actions = [
            (turn-switch-on {entity_id = "switch.computer_case_lighting";})
            (wait-till-available "light.computer_lights")
            (turn-light-on {entity_id = "light.computer_lights";} {effect = "Phased";})
          ];
        }

        # Turn computer lighting off.
        {
          alias = "computer lights off";
          description = "Turn off the computers lighting in sequence";
          mode = "single";
          triggers = [
            (turned-off {entity_id = "input_boolean.computer_lights_toggle";})
          ];
          actions = [
            (turn-light-off {entity_id = "light.computer_lights";})
            {delay = {seconds = 4;};}
            (turn-switch-off {entity_id = "switch.computer_case_lighting";})
          ];
        }

        # Computer light key action.
        {
          alias = "computer light key action";
          description = "Toggle the computer light when pressing Key2";
          mode = "single";
          triggers = [
            (turned-on {entity_id = "binary_sensor.key_2";})
          ];
          actions = [
            {
              action = "input_boolean.toggle";
              target = {entity_id = "input_boolean.computer_lights_toggle";};
            }
          ];
        }

        # Computer light key led.
        {
          alias = "computer light key indicator";
          description = "Toggle the key2 LED when the computer light changes state";
          mode = "single";
          triggers = [
            {
              trigger = "state";
              entity_id = ["input_boolean.computer_lights_toggle"];
            }
          ];
          actions = [
            (set-light-to {
              input_entity_id = "input_boolean.computer_lights_toggle";
              target = {entity_id = "light.state_2_light";};
              color = [255 120 20];
            })
          ];
        }

        # Computer power key action.
        {
          alias = "computer power key action";
          description = "Toggle the computer when pressing Key1";
          mode = "single";
          triggers = [
            (turned-on {entity_id = "binary_sensor.key_1";})
          ];
          actions = [
            {
              action = "button.press";
              target = {entity_id = "button.computer_case_power_button";};
            }
          ];
        }

        # Computer power key led.
        {
          alias = "computer power key indicator";
          description = "Toggle the key1 LED when the computer power changes state";
          mode = "single";
          triggers = [
            {
              trigger = "state";
              entity_id = ["binary_sensor.computer_case_power_led"];
            }
          ];
          actions = [
            (set-light-to {
              input_entity_id = "binary_sensor.computer_case_power_led";
              target = {entity_id = "light.state_1_light";};
              color = [255 0 0];
            })
          ];
        }

        # Heating key action.
        {
          alias = "Heating key action";
          description = "Toggle the heating when pressing Key5";
          mode = "single";
          triggers = [
            (turned-on {entity_id = "binary_sensor.key_5";})
          ];
          actions = [
            {
              action = "switch.toggle";
              target = {entity_id = "switch.heating_switch";};
            }
          ];
        }

        # Heating key led.
        {
          alias = "Heating key indicator";
          description = "Toggle the key5 LED when the heating changes state";
          mode = "single";
          triggers = [
            {
              trigger = "state";
              entity_id = ["switch.heating_switch"];
            }
          ];
          actions = [
            (set-light-to {
              input_entity_id = "switch.heating_switch";
              target = {entity_id = "light.state_5_light";};
              color = [255 255 0];
            })
          ];
        }

        # Send notification for the doorbell downstairs.
        {
          alias = "downstairs doorbell phone notification";
          description = "Send notification for the doorbell downstairs";
          triggers = [
            (turned-on {entity_id = "binary_sensor.doorbell_button_downstairs";})
          ];
          actions = [
            (alarm-notification {
              to = "lucas";
              message = "Someone rang the doorbell downstairs";
            })
            (alarm-notification {
              to = "tamy";
              message = "Someone rang the doorbell downstairs";
            })
          ];
        }

        # Send notification for the doorbell upstairs.
        {
          alias = "upstairs doorbell phone notification";
          description = "Send notification for the doorbell upstairs";
          triggers = [
            (turned-on {entity_id = "binary_sensor.doorbell_button_upstairs";})
          ];
          actions = [
            (alarm-notification {
              to = "lucas";
              message = "Someone rang the doorbell upstairs";
            })
            (alarm-notification {
              to = "tamy";
              message = "Someone rang the doorbell upstairs";
            })
          ];
        }

        {
          alias = "testing light switch";
          description = "testing the light switch";
          mode = "single";
          triggers = [
            (turned-on {entity_id = "input_boolean.test_toggle";})
          ];
          actions = [
            {
              action = "light.toggle";
              data = {
                transition = 0;
                rgb_color = [38 162 105];
              };
              target = {
                entity_id = "light.state_6_light";
              };
            }
          ];
        }
      ];
    };
  };

  services.caddy = {
    virtualHosts."home-assistant.${config.role-configuration.domain}".extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.home-assistant.config.http.server_port}
    '';
  };
}
