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
        server_host = "::1";
        trusted_proxies = ["::1"];
        use_x_forwarded_for = true;
      };

      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};

      automation = let
        # When a state changes from `off` to `on`.
        turned_on = {entity_id}: {
          trigger = "state";
          entity_id = [entity_id];
          from = "off";
          to = "on";
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
        # Send notification for the doorbell downstairs.
        {
          alias = "downstairs doorbell phone notification";
          description = "Send notification for the doorbell downstairs";
          triggers = [
            (turned_on {entity_id = "binary_sensor.doorbell_button_downstairs";})
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
            (turned_on {entity_id = "binary_sensor.doorbell_button_upstairs";})
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
            (turned_on {entity_id = "input_boolean.test_toggle";})
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

  role-configuration.subdomains = ["home-assistant"];

  services.nginx = {
    enable = true;

    virtualHosts."home-assistant.${config.role-configuration.host-name}.${config.role-configuration.domain}" = {
      sslCertificate = "/etc/ssl/local/_wildcard.central.home.pem";
      sslCertificateKey = "/etc/ssl/local/_wildcard.central.home-key.pem";
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.home-assistant.config.http.server_port}";
        proxyWebsockets = true;
      };
    };
  };
}
