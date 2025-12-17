{
  config,
  lib,
  pkgs,
  ...
}: let
  make-packages = configuration:
    with configuration.esphome; [
      (pkgs.writeShellScriptBin "upload-${name}" ''
        ${lib.getExe pkgs.esphome} compile /home/${config.home.username}/esphome/${name}.yaml
        ${lib.getExe pkgs.esphome} upload /home/${config.home.username}/esphome/${name}.yaml --device ${configuration.wifi.use_address}
      '')
    ];

  # HACK: to support !secret syntax. Ideally this can be solved in a nicer fashion.
  ssid-secret = 32123456789;
  password-secret = 98123456789;

  base-configuration = {
    esp32 = {
      board = "nodemcu-32s";
      framework = {
        type = "arduino";
      };
    };

    logger = {};

    prometheus = {};

    api.password = "";

    ota = {
      platform = "esphome";
      password = "";
    };

    wifi = {
      ssid = ssid-secret;
      password = password-secret;
    };

    status_led = {
      pin = "GPIO2";
    };
  };

  to-yaml = configuration:
    configuration
    |> lib.recursiveUpdate base-configuration
    |> lib.generators.toYAML {}
    |> builtins.replaceStrings [(toString password-secret)] ["!secret wifi_password"]
    |> builtins.replaceStrings [(toString ssid-secret)] ["!secret wifi_name"];
in {
  build = configuration: {
    home.packages = make-packages configuration;

    home.file."esphome/${configuration.esphome.name}.yaml".text = to-yaml configuration;

    home.activation.linkSecret = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ln -sf /run/agenix/esphome-secrets.yaml /home/${config.home.username}/esphome/secrets.yaml
    '';
  };
}
