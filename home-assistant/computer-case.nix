{
  lib,
  pkgs,
  config,
  ...
}: let
  helper = import ./helper.nix {inherit lib;};

  computer-case-config = {
    esphome = {
      name = "computer-case";
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
      use_address = "192.168.188.86";
    };

    status_led = {
      pin = "GPIO2";
    };
  };

  computer-case-yaml = helper.to-yaml computer-case-config;

  upload-computer-case = pkgs.writeShellScriptBin "upload-computer-case" ''
    ${lib.getExe pkgs.esphome} compile /home/${config.home.username}/esphome/computer-case.yaml
    ${lib.getExe pkgs.esphome} upload /home/${config.home.username}/esphome/computer-case.yaml
  '';
in {
  home.packages = [upload-computer-case];

  home.file."esphome/computer-case.yaml".text = computer-case-yaml;

  home.activation.linkSecret = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sf /run/agenix/esphome-secrets.yaml /home/${config.home.username}/esphome/secrets.yaml
  '';
}
